module Responders
  # Responder to automatically set flash messages based on I18n API. It checks for
  # message based on the current action, but also allows defaults to be set, using
  # the following order:
  #
  #   flash.controller_name.action_name.status
  #   flash.actions.action_name.status
  #
  # So, if you have a CarsController, create action, it will check for:
  #
  #   flash.cars.create.status
  #   flash.actions.create.status
  #
  # The statuses can be :success (when the object can be created, updated
  # or destroyed with success) or :failure (when the objecy cannot be created
  # or updated).
  #
  # The resource_name given is available as interpolation option, this means you can set:
  #
  #   flash:
  #     actions:
  #       create:
  #         success: "Hooray! {{resource_name}} was successfully created!"
  #
  # But sometimes, flash messages are not that simple. Going back
  # to cars example, you might want to say the brand of the car when it's
  # updated. Well, that's easy also:
  #
  #   flash:
  #     cars:
  #       update:
  #         success: "Hooray! You just tuned your {{car_brand}}!"
  #
  # Since :car_name is not available for interpolation by default, you have
  # to overwrite interpolation_options in your controller.
  #
  #   def interpolation_options
  #     { :car_brand => @car.brand }
  #   end
  #
  # Then you will finally have:
  #
  #   'Hooray! You just tuned your Aston Martin!'
  #
  # If your controller is namespaced, for example Admin::CarsController,
  # the messages will be checked in the following order:
  #
  #   flash.admin.cars.create.status
  #   flash.admin.actions.create.status
  #   flash.cars.create.status
  #   flash.actions.create.status
  #
  module FlashResponder
    def navigation_behavior(error)
      super

      unless get?
        status = has_errors? ? :failure : :success

        resource_name = if resource.class.respond_to?(:human_name)
          resource.class.human_name
        else
          resource.class.name.underscore.humanize
        end

        options = {
          :default => flash_defaults_by_namespace(status),
          :resource_name => resource_name
        }

        if controller.respond_to?(:interpolation_options, true)
          options.merge!(controller.send(:interpolation_options))
        end

        message = ::I18n.t options[:default].shift, options
        controller.send(:flash)[status] = message unless message.blank?
      end
    end

  protected
  
    def flash_defaults_by_namespace(status)
      defaults = []
      slices   = controller.controller_path.split('/')

      while slices.size > 0
        defaults << :"flash.#{slices.fill(controller.controller_name, -1).join('.')}.#{controller.action_name}.#{status}"
        defaults << :"flash.#{slices.fill(:actions, -1).join('.')}.#{controller.action_name}.#{status}"
        slices.shift
      end

      defaults << ""
    end
  end
end