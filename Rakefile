# encoding: UTF-8

require 'bundler/gem_tasks'

require 'rake/testtask'
require 'rdoc/task'
require File.join(File.dirname(__FILE__), 'lib', 'responders', 'version')

desc 'Default: run unit tests'
task :default => :test

desc 'Test Responders'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for Responders'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Responders'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
