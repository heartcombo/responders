# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "responders/version"

Gem::Specification.new do |s|
  s.name        = "responders"
  s.version     = Responders::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "A set of Rails 3 responders to dry up your application"
  s.email       = "contact@plataformatec.com.br"
  s.homepage    = "http://github.com/plataformatec/responders"
  s.description = "A set of Rails 3 responders to dry up your application"
  s.authors     = ['José Valim']

  s.rubyforge_project = "responders"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency "railties", "~> 3.1"
end
