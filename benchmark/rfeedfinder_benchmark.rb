require "benchmark"
require "rubygems"

sites = [
	"log.damog.net",
	"http://cnn.com",
	"scripting.com",
	"mx.planetalinux.org",
	"http://feedproxy.google.com/UniversoPlanetaLinux",
]

Benchmark.bm do |x|
	sites.each do |site|
		puts "#{site}:"

		puts " feedbag"
		x.report {
			require 'feedbag'
			Feedbag.find(site)
		}

		puts "  rfeedfinder"
		x.report {
			require 'rfeedfinder'
			Rfeedfinder.feed(site)
		}

	end
end

