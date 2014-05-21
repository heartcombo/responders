require 'test_helper'

class LocationResponder < ActionController::Responder
  include Responders::LocationResponder
end

class LocationsController < ApplicationController
  self.responder = LocationResponder

  respond_to :html
  before_filter :set_resource

  def create
    respond_with @resource, location: -> { 'given_location' }
  end

  def update
    respond_with @resource, location: 'given_location'
  end

  def set_resource
    @resource = Address.new
    @resource.errors[:fail] << "FAIL" if params[:fail]
  end
end

class LocationResponderTest < ActionController::TestCase
  tests LocationsController

  def test_redirects_to_block_location_on_success
    post :create
    assert_redirected_to 'given_location'
  end

  def test_renders_page_on_fail
    post :create, fail: true
    assert @response.body.include?('new.html.erb')
  end

  def test_redirects_to_plain_string
    post :update
    assert_redirected_to 'given_location'
  end
end
