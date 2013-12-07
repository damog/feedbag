# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = %q{feedbag}
  s.version = "0.9.2"
  s.homepage = "http://github.com/damog/feedbag"
  s.rubyforge_project = "feedbag"
 
  s.authors = ["David Moreno"]
  s.date = %q{2013-12-07}
  s.description = %q{Ruby's favorite feed auto-discoverty tool}
  s.email = %q{david@axiombox.com}
  s.extra_rdoc_files = ["README.markdown", "COPYING"]
  s.files = ["lib/feedbag.rb", "benchmark/rfeedfinder_benchmark.rb", "bin/feedbag"]
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.markdown"]
  s.summary = %q{Ruby's favorite feed auto-discovery tool}
  s.add_dependency("hpricot", '>= 0.6') 
  s.bindir = 'bin'
  s.default_executable = %q{feedbag}
  s.executables = ["feedbag"]
end

