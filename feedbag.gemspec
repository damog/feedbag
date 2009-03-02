# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = %q{feedbag}
  s.version = "0.5.9"
	s.homepage = "http://axiombox.com/feedbag"
	s.rubyforge_project = "feedbag"
 
  s.authors = ["Axiombox", "David Moreno"]
  s.date = %q{2009-02-10}
  s.description = %q{Ruby's favorite feed auto-discoverty tool}
  s.email = %q{david@axiombox.com}
  s.extra_rdoc_files = ["README.markdown", "COPYING"]
  s.files = ["lib/feedbag.rb"]
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.markdown"]
  s.summary = %q{Ruby's favorite feed auto-discovery tool}
	s.add_dependency("hpricot", '>= 0.6') 
end

