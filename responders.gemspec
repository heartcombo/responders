# -*- encoding: utf-8 -*-
# frozen_string_literal: true

$:.unshift File.expand_path("../lib", __FILE__)
require "responders/version"

Gem::Specification.new do |s|
  s.name        = "responders"
  s.version     = Responders::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "A set of Rails responders to dry up your application"
  s.email       = "heartcombo.oss@gmail.com"
  s.homepage    = "https://github.com/heartcombo/responders"
  s.description = "A set of Rails responders to dry up your application"
  s.authors     = ["José Valim"]
  s.license     = "MIT"
  s.metadata    = {
    "homepage_uri"    => "https://github.com/heartcombo/responders",
    "changelog_uri"   => "https://github.com/heartcombo/responders/blob/main/CHANGELOG.md",
    "source_code_uri" => "https://github.com/heartcombo/responders",
    "bug_tracker_uri" => "https://github.com/heartcombo/responders/issues",
  }

  s.required_ruby_version = ">= 2.7.0"

  s.files         = Dir["CHANGELOG.md", "MIT-LICENSE", "README.md", "lib/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency "railties", ">= 7.0"
  s.add_dependency "actionpack", ">= 7.0"

  s.add_development_dependency "mocha"
  s.add_development_dependency "rails-controller-testing"
end
