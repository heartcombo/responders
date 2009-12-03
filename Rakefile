# encoding: UTF-8

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), 'lib', 'responders', 'version')

desc 'Default: run unit tests'
task :default => :test

desc 'Test Responders'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
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

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "responders"
    s.version = Responders::VERSION
    s.summary = "A set of Rails 3 responders to dry up your application"
    s.email = "contact@plataformatec.com.br"
    s.homepage = "http://github.com/plataformatec/responders"
    s.description = "A set of Rails 3 responders to dry up your application"
    s.authors = ['José Valim']
    s.files =  FileList["[A-Z]*", "lib/**/*", "init.rb"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end
