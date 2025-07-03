#!/usr/bin/ruby
# frozen_string_literal: true

# See COPYING before using this software.

require "nokogiri"
require "async/http/internet/instance"
require "async/http/middleware/location_redirector"

class AsyncInternetWithRedirect < Async::HTTP::Internet
  protected

    def make_client(endpoint)
      ::Protocol::HTTP::AcceptEncoding.new(
        Async::HTTP::Middleware::LocationRedirector.new(Async::HTTP::Client.new(endpoint, **@options))
      )
    end
end

class Feedbag
  VERSION = "2.0.0"
  CONTENT_TYPES = [
    "application/x.atom+xml",
    "application/atom+xml",
    "application/xml",
    "text/xml",
    "application/rss+xml",
    "application/rdf+xml",
    "application/json",
    "application/feed+json"
  ].freeze

  class << self
    # (see #feed?)
    def feed?(url)
      new.feed?(url)
    end

    # @param url [String]
    # @param options [Hash]
    # @return (see #find)
    def find(url, options = {})
      new(options: options).find(url, **options)
    end
  end

  def initialize(options: nil)
    @feeds = []
    @options = options || {}
    @options["User-Agent"] ||= "Feedbag/#{VERSION}"
  end

  FEED_SCHEME_RE = %r{^feed://}
  def feed?(url)
    # use LWR::Simple.normalize some time
    url_uri = URI.parse(url)
    url = "#{url_uri.scheme or "http"}://#{url_uri.host}#{url_uri.path}"
    url << "?#{url_uri.query}" if url_uri.query

    # hack:
    url.sub!(FEED_SCHEME_RE, "http://")

    res = Feedbag.find(url)
    (res.size == 1) && (res.first == url)
  end

  XML_RE = /.xml$/
  SERVICE_FEED_XPATH = "//link[@rel='alternate' or @rel='service.feed'][@href][@type]"
  JSON_FEED_XPATH = "//link[@rel='alternate' and @type='application/json'][@href]"
  def find(url, _options = {})
    url_uri = URI.parse(url)
    url = nil
    if url_uri.scheme.nil?
      url = "http://#{url_uri}"
    elsif url_uri.scheme == "feed"
      return add_feed(url_uri.to_s.sub(FEED_SCHEME_RE, "http://"), nil)
    else
      url = url_uri.to_s
    end
    # url = "#{url_uri.scheme or 'http'}://#{url_uri.host}#{url_uri.path}"

    # check if feed_valid is avail
    begin
      require "feed_validator"
      v = W3C::FeedValidator.new
      v.validate_url(url)
      return add_feed(url, nil) if v.valid?
    rescue LoadError
      # scoo
    rescue REXML::ParseException
      # usually indicates timeout
      # TODO: actually find out timeout. use Terminator?
      # $stderr.puts "Feed looked like feed but might not have passed validation or timed out"
    rescue => e
      warn "#{e.class} error occurred with: `#{url}': #{e.message}"
    end

    begin
      headers = @options.slice("User-Agent")
      Sync do
        response = AsyncInternetWithRedirect.get(url, headers)

        content_type = response.headers["content-type"].gsub(/;.*$/, "").downcase
        next add_feed(url, nil) if CONTENT_TYPES.include?(content_type)

        doc = Nokogiri::HTML(response.read)

        @base_uri = (doc.at("base")["href"] if doc.at("base") && doc.at("base")["href"])

        # first with links
        (doc / "atom:link").each do |l|
          next unless l["rel"] && l["href"].present?

          add_feed(l["href"], url, @base_uri) if l["type"] && CONTENT_TYPES.include?(l["type"].downcase.strip) && (l["rel"].downcase == "self")
        end

        doc.xpath(SERVICE_FEED_XPATH).each do |l|
          add_feed(l["href"], url, @base_uri) if CONTENT_TYPES.include?(l["type"].downcase.strip)
        end

        doc.xpath(JSON_FEED_XPATH).each do |e|
          add_feed(e["href"], url, @base_uri) if looks_like_feed?(e["href"])
        end

        (doc / "a").each do |a|
          next unless a["href"]

          add_feed(a["href"], url, @base_uri) if looks_like_feed?(a["href"]) && (a["href"].include?("/") || a["href"] =~ /#{url_uri.host}/)

          next unless a["href"]

          add_feed(a["href"], url, @base_uri) if looks_like_feed?(a["href"])
        end

        # Added support for feeds like http://tabtimes.com/tbfeed/mashable/full.xml
        add_feed(url, nil) if url.match(XML_RE) && doc.root && doc.root["xml:base"] && (doc.root["xml:base"].strip == url.strip)
      ensure
        response&.close
      end
    rescue Timeout::Error => e
      warn "Timeout error occurred with `#{url}: #{e}'"
    rescue => e
      warn "#{e.class} error occurred with: `#{url}': #{e.message}"
    end
    return @feeds
  end

  FEED_RE = %r{(\.(rdf|xml|rss)(\?([\w'\-%]?(=[\w'\-%.]*)?(&|#|\+|;)?)+)?(:[\w'\-%]+)?$|feed=(rss|atom)|(atom|feed)/?$)}i
  def looks_like_feed?(url)
    FEED_RE.match?(url)
  end

  def add_feed(feed_url, orig_url, base_uri = nil)
    # puts "#{feed_url} - #{orig_url}"
    url = feed_url.sub(/^feed:/, "").strip

    if base_uri
      #	url = base_uri + feed_url
      url = URI.parse(base_uri).merge(feed_url).to_s
    end

    begin
      uri = URI.parse(url)
    rescue
      puts "Error with `#{url}'"
      exit 1
    end
    unless uri.absolute?
      orig = URI.parse(orig_url)
      url = orig.merge(url).to_s
    end

    # verify url is really valid
    @feeds.push(url) unless @feeds.include?(url)
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    puts "usage: feedbag url"
  else
    puts Feedbag.find ARGV.first
  end
end
