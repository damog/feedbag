#!/usr/bin/ruby

#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
# 
# Copyright (C) 2008 David Moreno <david@axiombox.com>
# 
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
# 
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
# 
#  0. You just DO WHAT THE FUCK YOU WANT TO.

# Originally wrote by David Moreno <david@axiombox.com>
#  mainly based on Benjamin Trott's Feed::Find

require "rubygems"
require "hpricot"
require "open-uri"
require "net/http"

module Feedbag

	@content_types = [
		'application/x.atom+xml',
		'application/atom+xml',
		'application/xml',
		'text/xml',
		'application/rss+xml',
		'application/rdf+xml',
	]

	@debug = 1

	$feeds = []
	$base_uri = nil

	def self.find(url)
		$feeds = []
		begin
			html = open(url) do |f|
				if @content_types.include?(f.content_type.downcase)
					return self.add_feed(url, nil)
				end

				doc = Hpricot(f.read)

				if doc.at("base") and doc.at("base")["href"]
					$base_uri = doc.at("base")["href"]
				else
					$base_uri = nil
				end

				# first with links
				(doc/"link").each do |l|
					next unless l["rel"]
					if l["type"] and @content_types.include?(l["type"].downcase.strip) and (l["rel"].downcase =~ /alternate/i or l["rel"] == "service.feed")
						self.add_feed(l["href"], url, $base_uri)
					end
				end
				
				(doc/"a").each do |a|
					next unless a["href"]
					if(
						a["href"] =~ /\.(rdf|xml|rdf)$/i or 
						a["href"] =~ /feed=(rss2|atom)/i or 
						a["href"] =~ /(atom|feed)\/$/i)

						self.add_feed(a["href"], url, $base_uri)
					end
				end

			end
		rescue OpenURI::HTTPError => the_error
			puts "Error ocurred with `#{url}': #{the_error}"
		end
		
		$feeds
	end

	def self.add_feed(feed_url, orig_url, base_uri = nil)
		puts "#{feed_url} - #{orig_url}"
		url = feed_url.sub(/^feed:/, '').strip

		if base_uri
			url = base_uri + feed_url
			puts "base_uri: #{base_uri}" if @debug
			puts "orig_url: #{orig_url}" if @debug
			puts "feed_url: #{feed_url}" if @debug
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
		$feeds.push(url) if self._is_http_valid(URI.parse(url), url)
	end

	def self._is_http_valid(uri, url)
		req = Net::HTTP.get_response(uri)
		case req
			when Net::HTTPSuccess then
				return true
			else
				guess_url = "#{uri.scheme}://#{uri.host}#{uri.path}"
				return false if guess_url == url
				return true if self._is_http_valid(URI.parse(guess_url), guess_url)
		end
	end
end

