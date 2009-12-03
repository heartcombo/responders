require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

module Rails
  module Generators
    class RespondersControllerGenerator < ScaffoldControllerGenerator
      def self.source_root
        @source_root ||= File.expand_path("templates", File.dirname(__FILE__))
      end
    protected
      def flash?
        !ApplicationController.responder.ancestors.include?(Responders::FlashResponder)
      end
    end
  end
end