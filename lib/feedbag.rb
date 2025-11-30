#!/usr/bin/ruby

# See COPYING before using this software.

require "rubygems"
require "nokogiri"
require "open-uri"
require "net/http"
require "logger"
require_relative "feedbag/version"

begin
  require "addressable/uri"
rescue LoadError
  # addressable will be loaded after bundle install
end

class Feedbag

  # Configurable logger for error output
  # Default writes to $stderr. Can be set to Rails.logger or any Logger-compatible object.
  #
  # @example Silence all output
  #   Feedbag.logger = Logger.new('/dev/null')
  #
  # @example Use Rails logger
  #   Feedbag.logger = Rails.logger
  #
  class << self
    attr_writer :logger

    def logger
      @logger ||= default_logger
    end

    private

    def default_logger
      logger = Logger.new($stderr)
      logger.formatter = proc { |severity, _datetime, _progname, msg| "#{msg}\n" }
      logger
    end
  end
  CONTENT_TYPES = [
    'application/x.atom+xml',
    'application/atom+xml',
    'application/xml',
    'text/xml',
    'application/rss+xml',
    'application/rdf+xml',
    'application/json',
    'application/feed+json'
  ].freeze

  def self.feed?(url)
    new.feed?(url)
  end

  def self.find(url, options = {})
    new(options: options).find(url, options)
  end

  def initialize(options: nil)
    @feeds = []
    @options = options || {}
    @options["User-Agent"] ||= "Feedbag/#{VERSION}"
  end

  # Normalize a URL to handle non-ASCII characters (IRIs)
  # This converts internationalized URLs to valid ASCII URIs
  def self.normalize_url(url)
    return url if url.nil? || url.empty?
    if defined?(Addressable::URI)
      Addressable::URI.parse(url).normalize.to_s
    else
      url
    end
  rescue Addressable::URI::InvalidURIError
    url
  end

  def feed?(url)
    # Normalize URL to handle non-ASCII characters
    normalized_url = Feedbag.normalize_url(url)
    url_uri = URI.parse(normalized_url)
    url = "#{url_uri.scheme or 'http'}://#{url_uri.host}#{url_uri.path}"
    url << "?#{url_uri.query}" if url_uri.query

      # hack:
      url.sub!(/^feed:\/\//, 'http://')

    res = Feedbag.find(url)
    if res.size == 1 and res.first == url
      return true
    else
      return false
    end
  end

  def find(url, options = {})
    # Normalize URL to handle non-ASCII characters
    normalized_url = Feedbag.normalize_url(url)
    url_uri = URI.parse(normalized_url)
    url = nil
    if url_uri.scheme.nil?
      url = "http://#{url_uri.to_s}"
    elsif url_uri.scheme == "feed"
      return self.add_feed(url_uri.to_s.sub(/^feed:\/\//, 'http://'), nil)
    else
      url = url_uri.to_s
    end
    #url = "#{url_uri.scheme or 'http'}://#{url_uri.host}#{url_uri.path}"

    # check if feed_valid is avail
    begin
      require "feed_validator"
      v = W3C::FeedValidator.new
      v.validate_url(url)
      return self.add_feed(url, nil) if v.valid?
    rescue LoadError
      # scoo
    rescue REXML::ParseException
      # usually indicates timeout
      # TODO: actually find out timeout. use Terminator?
      # $stderr.puts "Feed looked like feed but might not have passed validation or timed out"
    rescue => ex
      Feedbag.logger.error "#{ex.class} error occurred with: `#{url}': #{ex.message}"
    end

    begin
      html = URI.open(url, @options) do |f|
        content_type = f.content_type.downcase
        if content_type == "application/octet-stream" # open failed
          content_type = f.meta["content-type"].gsub(/;.*$/, '')
        end
        if CONTENT_TYPES.include?(content_type)
          return self.add_feed(url, nil)
        end

        doc = Nokogiri::HTML(f.read)

        if doc.at("base") and doc.at("base")["href"]
          @base_uri = doc.at("base")["href"]
        else
          @base_uri = nil
        end

        # first with links
        (doc/"atom:link").each do |l|
          next unless l["rel"] && l["href"].present?
          if l["type"] and CONTENT_TYPES.include?(l["type"].downcase.strip) and l["rel"].downcase == "self"
            self.add_feed(l["href"], url, @base_uri)
          end
        end

        doc.xpath("//link[@rel='alternate' or @rel='service.feed'][@href][@type]").each do |l|
          if CONTENT_TYPES.include?(l['type'].downcase.strip)
            self.add_feed(l["href"], url, @base_uri)
          end
        end

        doc.xpath("//link[@rel='alternate' and @type='application/json'][@href]").each do |e|
          self.add_feed(e['href'], url, @base_uri) if self.looks_like_feed?(e['href'])
        end

        (doc/"a").each do |a|
          next unless a["href"]
          if self.looks_like_feed?(a["href"]) and (a["href"] =~ /\// or a["href"] =~ /#{url_uri.host}/)
            self.add_feed(a["href"], url, @base_uri)
          end
        end

        (doc/"a").each do |a|
          next unless a["href"]
          if self.looks_like_feed?(a["href"])
            self.add_feed(a["href"], url, @base_uri)
          end
        end

        # Added support for feeds like http://tabtimes.com/tbfeed/mashable/full.xml
        if url.match(/.xml$/) and doc.root and doc.root["xml:base"] and doc.root["xml:base"].strip == url.strip
          self.add_feed(url, nil)
        end
      end
    rescue Timeout::Error => err
      Feedbag.logger.error "Timeout error occurred with `#{url}: #{err}'"
    rescue OpenURI::HTTPError => the_error
      Feedbag.logger.error "Error occurred with `#{url}': #{the_error}"
    rescue SocketError => err
      Feedbag.logger.error "Socket error occurred with: `#{url}': #{err}"
    rescue => ex
      Feedbag.logger.error "#{ex.class} error occurred with: `#{url}': #{ex.message}"
    ensure
      return @feeds
    end

  end

  def looks_like_feed?(url)
    if url =~ /(\.(rdf|xml|rss)(\?([\w'\-%]?(=[\w'\-%.]*)?(&|#|\+|\;)?)+)?(:[\w'\-%]+)?$|feed=(rss|atom)|(atom|feed)\/?$)/i
      true
    else
      false
    end
  end

  def add_feed(feed_url, orig_url, base_uri = nil)
    # puts "#{feed_url} - #{orig_url}"
    url = feed_url.sub(/^feed:/, '').strip

    # Normalize URL to handle non-ASCII characters
    url = Feedbag.normalize_url(url)

    if base_uri
      #	url = base_uri + feed_url
      normalized_base = Feedbag.normalize_url(base_uri)
      url = URI.parse(normalized_base).merge(url).to_s
    end

    begin
      uri = URI.parse(url)
    rescue => ex
      Feedbag.logger.error "Error parsing URL `#{url}': #{ex.message}"
      return
    end
    unless uri.absolute?
      normalized_orig = Feedbag.normalize_url(orig_url)
      orig = URI.parse(normalized_orig)
      url = orig.merge(url).to_s
    end

    # verify url is really valid
    @feeds.push(url) unless @feeds.include?(url)# if self._is_http_valid(URI.parse(url), orig_url)
  end

  # not used. yet.
  def _is_http_valid(uri, orig_url)
    req = Net::HTTP.get_response(uri)
    orig_uri = URI.parse(orig_url)
    case req
    when Net::HTTPSuccess then
      return true
    else
      return false
    end
  end
end

if __FILE__ == $0
  if ARGV.size == 0
    puts 'usage: feedbag url'
  else
    puts Feedbag.find ARGV.first
  end
end
