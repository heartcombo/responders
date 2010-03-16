module Responders
  autoload :FlashResponder,     'responders/flash_responder'
  autoload :HttpCacheResponder, 'responders/http_cache_responder'
  autoload :ControllerMethod,   'responders/controller_method'

  class Railtie < ::Rails::Railtie
    railtie_name :responders

    config.generators.scaffold_controller = :responders_controller

    # Add load paths straight to I18n, so engines and application can overwrite it.
    require 'active_support/i18n'
    I18n.load_path << File.expand_path('../responders/locales/en.yml', __FILE__)

    initializer "responders.flash_responder" do
      if config.responders.flash_keys
        Responders::FlashResponder.flash_keys = config.responders.flash_keys 
      end
    end
    
    initializer "responders.extend_action_controller" do
      ActionController::Base.extend Responders::ControllerMethod
    end
  end
end