class RespondersInstallGenerator < Rails::Generators::Base
  def self.source_root
    @_source_root ||= File.expand_path("..", __FILE__)
  end

  desc "Creates an initializer with default responder configuration and copy locale file"

  def create_responder_initializer
    create_file "config/initializers/responders.rb", <<-FILE
class ApplicationResponder < ActionController::Responder
  include Responders::FlashResponder
  include Responders::HttpCacheResponder
end

ApplicationController.respond_to :html
ApplicationController.responder = ApplicationResponder
    FILE
  end

  def copy_locale
    copy_file "../responders/locales/en.yml", "config/locales/responders.en.yml"
  end
end