# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{feedbag}
  s.version = "0.10"
  s.homepage = "http://github.com/damog/feedbag"
  s.rubyforge_project = "feedbag"
  s.licenses = ["MIT"]

  s.authors = ["David Moreno"]

  s.date = %q{2019-01-13}

  s.description = %q{Ruby's favorite feed auto-discovery tool}
  s.email = %q{damog@damog.net}

  s.extra_rdoc_files = ["README.markdown", "COPYING"]
  s.files = ["lib/feedbag.rb", "benchmark/rfeedfinder_benchmark.rb", "bin/feedbag"]
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.markdown"]
  s.summary = %q{RSS/Atom feed auto-discovery tool}

  s.add_runtime_dependency 'nokogiri', '~> 1.8', '>= 1.8.2'
  s.add_dependency('open_uri_redirections', '~> 0.2')

  s.add_development_dependency 'shoulda', '~> 3'
  s.add_development_dependency 'mocha', '~> 0.12', '>= 0.12.0'
  s.add_development_dependency 'webmock', '~> 3'

  s.bindir = 'bin'
  s.default_executable = %q{feedbag}
  s.executables = ["feedbag"]
end
