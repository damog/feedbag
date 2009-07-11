require File.dirname(__FILE__) + '/test_helper'

class AtomAutoDiscoveryTest < Test::Unit::TestCase
	def test_autodisc
		base_url = "http://diveintomark.org/tests/client/autodiscovery/"
		url = base_url + "html4-001.html"

		i = 1
		puts "trying now with #{url}"
		while(i)
			puts
			i = 0 # unless otherwise found

			f = Feedbag.find url

			assert_instance_of Array, f
			assert f.size == 1, "Feedbag didn't find a feed on #{url} or found more than one"

			puts " found #{f[0]}"
			feed = Hpricot(open(f[0]))
	
			(feed/"link").each do |l|
				next unless l["rel"] == "alternate"
				assert_equal l["href"], url
			end

			# ahora me voy al siguiente
			html = Hpricot(open(url))
			(html/"link").each do |l|
				next unless l["rel"] == "next"
				url = URI.parse(base_url).merge(l["href"]).to_s
				puts "trying now with #{url}"
				i = 1
			end
		
		end	
	end


end
