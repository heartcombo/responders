require 'bundler/setup'
require 'minitest/autorun'
require 'mocha/setup'

# Configure Rails
ENV["RAILS_ENV"] = "test"

require 'active_support'
require 'action_controller'
require 'active_model'
require 'rails/engine'
require 'rails/railtie'

$:.unshift File.expand_path('../../lib', __FILE__)
require 'responders'

I18n.enforce_available_locales = true
I18n.load_path << File.expand_path('../locales/en.yml', __FILE__)
I18n.reload!

Responders::Routes = ActionDispatch::Routing::RouteSet.new
Responders::Routes.draw do
  resources :news
  get '/admin/:action', :controller => "admin/addresses"
  get '/:controller(/:action(/:id))'
end

class ApplicationController < ActionController::Base
  include Responders::Routes.url_helpers

  self.view_paths = File.join(File.dirname(__FILE__), 'views')
  respond_to :html, :xml
end

class ActiveSupport::TestCase
  setup do
    @routes = Responders::Routes
  end
end

module ActionDispatch
  class Flash
    class FlashHash
      def used_keys
        # Rails 3 || Rails 4
        @used || @discard
      end
    end
  end
end

class Model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :persisted, :updated_at
  alias :persisted? :persisted

  def persisted?
    @persisted
  end

  def to_xml(*args)
    "<xml />"
  end

  def initialize(updated_at=nil)
    @persisted = true
    self.updated_at = updated_at
  end
end

class Address < Model
end

class User < Model
end

class News < Model
end

module MyEngine
  class Business < Rails::Engine
    isolate_namespace MyEngine
    extend ActiveModel::Naming
  end
end
