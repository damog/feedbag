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

module Feedbag

	@content_types = [
		'application/x.atom+xml',
		'application/atom+xml',
		'application/xml',
		'text/xml',
		'application/rss+xml',
		'application/rdf+xml',
	]

	$feeds = []

	def self.find(url)
		$feeds = []
		begin
			html = open(url) do |f|
				if @content_types.include?(f.content_type.downcase)
					return self.add_feed(url)
				end

				doc = Hpricot(f.read)

				# first with links
				(doc/"link").each do |l|
					next unless l["rel"]
					if l["type"] and @content_types.include?(l["type"].downcase.strip) and (l["rel"].downcase =~ /alternate/i or l["rel"] == "service.feed")
						self.add_feed(l["href"], url)
					end
				end
				
				(doc/"a").each do |a|
					next unless a["href"]
					if(
						a["href"] =~ /\.(rdf|xml|rdf)$/i or 
						a["href"] =~ /feed=(rss2|atom)/i or 
						a["href"] =~ /(atom|feed)\/$/i)

						self.add_feed(a["href"], url)
					end
				end

			end
		rescue OpenURI::HTTPError => the_error
			puts "Error ocurred with `#{url}': #{the_error}"
		end
		
		$feeds
	end

	def self.add_feed(feed_url, orig_url)
		url = feed_url.sub(/^feed:/, '').strip

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
		$feeds.push(url)
	end
end

