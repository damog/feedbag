# frozen_string_literal: true

require 'benchmark'
require 'rubygems'

sites = [
  'log.damog.net',
  'http://cnn.com',
  'scripting.com',
  'mx.planetalinux.org',
  'http://feedproxy.google.com/UniversoPlanetaLinux'
]

Benchmark.bm do |x|
  sites.each do |site|
    puts "#{site}:"

    puts ' feedbag'
    x.report do
      require 'feedbag'
      Feedbag.find(site)
    end

    puts '  rfeedfinder'
    x.report do
      require 'rfeedfinder'
      Rfeedfinder.feed(site)
    end
  end
end
