require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

module Rails
  module Generators
    class RespondersControllerGenerator < ScaffoldControllerGenerator
      source_root File.expand_path("../templates", __FILE__)

      protected

      def flash?
        if defined?(ApplicationController)
          !ApplicationController.responder.ancestors.include?(Responders::FlashResponder)
        else
          Rails.application.config.responders.flash_keys.blank?
        end
      end

      def orm_instance_update(params)
        if orm_instance.respond_to?(:update)
          orm_instance.update params
        else
          orm_instance.update_attributes params
        end
      end

      def controller_before_filter
        if ActionController::Base.respond_to?(:before_action)
          "before_action"
        else
          "before_filter"
        end
      end

      def attributes_params
        if strong_parameters_defined?
          "#{file_name}_params"
        else
          "params[:#{file_name}]"
        end
      end

      def strong_parameters_defined?
        defined?(ActionController::StrongParameters)
      end
    end
  end
end
