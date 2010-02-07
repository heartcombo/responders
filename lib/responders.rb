module Responders
  autoload :FlashResponder,     'responders/flash_responder'
  autoload :HttpCacheResponder, 'responders/http_cache_responder'

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
  end
end