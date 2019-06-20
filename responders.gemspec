# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "responders/version"

Gem::Specification.new do |s|
  s.name        = "responders"
  s.version     = Responders::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "A set of Rails responders to dry up your application"
  s.email       = "contact@plataformatec.com.br"
  s.homepage    = "https://github.com/plataformatec/responders"
  s.description = "A set of Rails responders to dry up your application"
  s.authors     = ["José Valim"]
  s.license     = "MIT"

  s.files         = Dir["CHANGELOG.md", "MIT-LICENSE", "README.md", "lib/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency "railties", ">= 4.2.0", "< 6.0"
  s.add_dependency "actionpack", ">= 4.2.0", "< 6.0"
end
