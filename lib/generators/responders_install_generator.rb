class RespondersInstallGenerator < Rails::Generators::Base
  desc "Creates an initializer file with default responder configuration"

  def create_responder_initializer
    create_file "config/initializers/responders.rb", <<-FILE
class #{Rails.application.class.name}Responder
  include FlashResponder
  include HttpCacheResponder
end

ApplicationController.responder = #{Rails.application.class.name}Responder
    FILE
  end
end