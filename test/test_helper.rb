require 'rubygems'

gem 'activesupport', '3.0.0.beta2'
gem 'activemodel', '3.0.0.beta2'
gem 'actionpack', '3.0.0.beta2'
gem 'railties', '3.0.0.beta2'

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

require 'active_support'
require 'action_controller'
require 'rails/railtie'

class ApplicationController < ActionController::Base
  respond_to :html, :xml
end

$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'responders'

I18n.load_path << File.join(File.dirname(__FILE__), 'locales', 'en.yml')
I18n.reload!

ActionController::Base.view_paths = File.join(File.dirname(__FILE__), 'views')

Responders::Routes = ActionDispatch::Routing::RouteSet.new
Responders::Routes.draw do |map|
  map.connect 'admin/:action', :controller => "admin/addresses"
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action'
end

class ActiveSupport::TestCase
  setup do
    @routes = Responders::Routes
  end
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