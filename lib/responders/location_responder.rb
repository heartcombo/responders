module Responders
  # Responder to accept callable objects as the redirect location.
  # Useful when you want to use the <tt>respond_with</tt> method with
  # a route that requires persisted objects, but the validation may fail.
  #
  #   class ThingsController < ApplicationController
  #     responders :location, :flash
  #     respond_to :html
  #
  #     def create
  #       @thing = Things.create(params[:thing])
  #       respond_with @thing, location: -> { thing_path(@thing) }
  #     end
  #   end
  #
  module LocationResponder
    def initialize(controller, resources, options = {})
      super

      if options[:location].respond_to?(:call)
        location = options.delete(:location)
        options[:location] = location.call unless has_errors?
      end
    end
  end
end
