require 'rubygems'

begin
  gem "test-unit"
rescue LoadError
end

begin
  gem "ruby-debug"
  require 'ruby-debug'
rescue LoadError
end

require 'test/unit'
require 'mocha'

# Configure Rails
ENV["RAILS_ENV"] = "test"
RAILS_ROOT = "anywhere"

require File.expand_path(File.dirname(__FILE__) + "/../../rails/vendor/gems/environment")
require 'active_support'
require 'action_controller'
require 'action_controller/test_case'

class ApplicationController < ActionController::Base
  respond_to :html, :xml
end

# Add IR to load path and load the main file
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'responders'

I18n.load_path << File.join(File.dirname(__FILE__), 'locales', 'en.yml')
I18n.reload!

ActionController::Base.view_paths = File.join(File.dirname(__FILE__), 'views')

ActionController::Routing::Routes.draw do |map|
  map.connect 'admin/:action', :controller => "admin/addresses"
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action'
end

class Model < Struct.new(:updated_at)
  attr_writer :new_record

  def new_record?
    @new_record || false
  end

  def to_xml(*args)
    "<xml />"
  end
end