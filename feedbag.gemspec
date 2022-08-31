# -*- encoding: utf-8 -*-

require_relative "lib/feedbag"

Gem::Specification.new do |s|
  s.name = %q{feedbag}
  s.version = Feedbag::VERSION
  s.homepage = "http://github.com/damog/feedbag"
  # s.rubyforge_project = "feedbag"
  s.licenses = ["MIT"]

  s.authors = ["David Moreno"]

  s.date = %q{2020-11-28}

  s.description = %q{Ruby's favorite feed auto-discovery tool}
  s.email = %q{damog@damog.net}

  s.extra_rdoc_files = ["README.markdown", "COPYING"]
  s.files = ["lib/feedbag.rb", "benchmark/rfeedfinder_benchmark.rb", "bin/feedbag"]
  # s.has_rdoc = true
  s.rdoc_options = ["--main", "README.markdown"]
  s.summary = %q{RSS/Atom feed auto-discovery tool}

  s.add_runtime_dependency 'nokogiri', '~> 1.8', '>= 1.8.2'

  s.add_development_dependency 'shoulda', '~> 3'
  s.add_development_dependency 'mocha', '~> 0.12', '>= 0.12.0'
  s.add_development_dependency 'webmock', '~> 3'
  s.add_development_dependency 'byebug', '~> 11'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'test-unit'

  s.bindir = 'bin'
  # s.default_executable = %q{feedbag}
  s.executables = ["feedbag"]
end
