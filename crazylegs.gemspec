# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "crazylegs/version"

Gem::Specification.new do |s|
  s.name        = "crazylegs"
  s.version     = Crazylegs::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Dave Copeland']
  s.email       = ['dave@opower.com']
  s.homepage    = ""
  s.summary     = %q{The two-legged OAuth used in a few OPOWER libraries}
  s.description = %q{Couldn't get two-legged OAuth working from existing Ruby libs, so this implements it "by-hand"}

  s.rubyforge_project = "crazylegs"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.add_development_dependency('sdoc')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('rake')
  s.add_development_dependency('rcov')
  s.add_development_dependency('grancher','~> 0.1.5')
  s.add_dependency('ruby-hmac', '~> 0.4.0')
end
