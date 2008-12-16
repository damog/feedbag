#!/usr/bin/ruby

require "../feedbag"
require "test/unit"
require "open-uri"
require "hpricot"
require "pp"

class AtomAutoDiscoveryTest < Test::Unit::TestCase
	def test_autodisc
		base_url = "http://diveintomark.org/tests/client/autodiscovery/"
		url = "html4-001.html"

		i = 1
		puts "trying now with #{url}"
		while(i)
			i = 0 # unless otherwise found

			f = Feedbag.find base_url + url

			assert_instance_of Array, f
			assert f.size == 1, "Feedbag didn't find a feed on #{base_url + url} or found more than one"

			puts " found #{f[0]}"
			feed = Hpricot(open(f[0]))
	
			(feed/"link").each do |l|
				next unless l["rel"] == "alternate"
				assert_equal l["href"], base_url + url
			end

			# ahora me voy al siguiente
			html = Hpricot(open(base_url + url))
			(html/"link").each do |l|
				next unless l["rel"] == "next"
				url = l["href"]
				puts "trying now with #{url}"
				i = 1
			end

		end	
	end


end
