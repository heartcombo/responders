module Responders
  autoload :FlashResponder,     'responders/flash_responder'
  autoload :HttpCacheResponder, 'responders/http_cache_responder'

  class Railtie < ::Rails::Railtie
    railtie_name :responders

    config.generators.scaffold_controller = :responders_controller

    initializer "responders.flash_responder" do
      if config.responders.flash_keys
        Responders::FlashResponder.flash_keys = config.responders.flash_keys 
      end
    end
  end if defined?(::Rails::Railtie)
end