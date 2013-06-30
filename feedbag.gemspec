# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = %q{feedbag}
  s.version = "0.9.1"
  s.homepage = "http://axiombox.com/feedbag"
  s.rubyforge_project = "feedbag"
 
  s.authors = ["Axiombox", "David Moreno", "Derek Willis"]
  s.date = %q{2012-03-16}
  s.description = %q{Ruby's favorite feed auto-discoverty tool}
  s.email = %q{david@axiombox.com}
  s.extra_rdoc_files = ["README.markdown", "COPYING"]
  s.files = ["lib/feedbag.rb", "benchmark/rfeedfinder_benchmark.rb", "bin/feedbag"]
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.markdown"]
  s.summary = %q{Ruby's favorite feed auto-discovery tool}
  s.add_dependency("nokogiri") 
  s.add_development_dependency "shoulda" 
  s.add_development_dependency "mocha", "~> 0.12.0"
  s.bindir = 'bin'
  s.default_executable = %q{feedbag}
  s.executables = ["feedbag"]
end

