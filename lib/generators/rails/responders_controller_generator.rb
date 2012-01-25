require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

module Rails
  module Generators
    class RespondersControllerGenerator < ScaffoldControllerGenerator
      source_root File.expand_path("../templates", __FILE__)

    protected

      def flash?
        target = if defined?(Rails.application) && Rails.application.parent.const_defined?(:ApplicationController)
          Rails.application.parent.const_get(:ApplicationController)
        elsif defined?(::ApplicationController)
          ::ApplicationController
        end

        if target
          !target.responder.ancestors.include?(Responders::FlashResponder)
        else
          true
        end
      end
    end
  end
end