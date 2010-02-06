class RespondersInstallGenerator < Rails::Generators::Base
  desc "Creates an initializer with default responder configuration"

  def create_responder_initializer
    create_file "config/initializers/responders.rb", <<-FILE
class ApplicationResponder
  include Responders::FlashResponder
  include Responders::HttpCacheResponder
end

ApplicationController.respond_to :html
ApplicationController.responder = ApplicationResponder
    FILE
  end
end