require File.dirname(__FILE__) + '/test_helper'

class Address
  attr_accessor :errors
  def self.human_name; 'Address'; end
  
  def initialize
    @errors = {}
  end
end

class FlashResponder < ActionController::Responder
  include Responders::FlashResponder
end

class AddressesController < ApplicationController
  before_filter :set_resource
  self.responder = FlashResponder

  def action
    respond_with(@resource)
  end
  alias :new     :action
  alias :create  :action
  alias :update  :action
  alias :destroy :action

protected

  def interpolation_options
    { :reference => 'Ocean Avenue' }
  end

  def set_resource
    @resource = Address.new
    @resource.errors[:fail] = true if params[:fail]
  end
end

module Admin
  class AddressesController < ::AddressesController
  end
end

class FlashResponderTest < ActionController::TestCase
  tests AddressesController

  def setup
    @controller.stubs(:polymorphic_url).returns("/")
  end

  def test_sets_success_flash_message_on_non_get_requests
    post :create
    assert_equal "Resource created with success", flash[:success]
  end

  def test_sets_failure_flash_message_on_not_get_requests
    post :create, :fail => true
    assert_equal "Resource could not be created", flash[:failure]
  end

  def test_does_not_set_flash_message_on_get_requests
    get :new
    assert flash.empty?
  end

  def test_sets_flash_message_for_the_current_controller
    put :update, :fail => true
    assert_equal "Oh no! We could not update your address!", flash[:failure]
  end

  def test_sets_flash_message_with_resource_name
    put :update
    assert_equal "Nice! Address was updated with success!", flash[:success]
  end

  def test_sets_flash_message_with_interpolation_options
    delete :destroy
    assert_equal "Successfully deleted the address at Ocean Avenue", flash[:success]
  end
end

class NamespacedFlashResponderTest < ActionController::TestCase
  tests Admin::AddressesController

  def setup
    @controller.stubs(:polymorphic_url).returns("/")
  end

  def test_sets_the_flash_message_based_on_the_current_controller
    put :update
    assert_equal "Admin updated address with success", flash[:success]
  end

  def test_sets_the_flash_message_based_on_namespace_actions
    post :create
    assert_equal "Admin created address with success", flash[:success]
  end

  def test_fallbacks_to_non_namespaced_controller_flash_message
    delete :destroy
    assert_equal "Successfully deleted the address at Ocean Avenue", flash[:success]
  end
end

# 
# class AddressesController < InheritedResources::Base
#   respond_to :xml
#   protected
#     def interpolation_options
#       { :reference => 'Ocean Avenue' }
#     end
# end
# 
# module Admin; end
# class Admin::AddressesController < InheritedResources::Base
#   respond_to :xml
#   protected
#     def interpolation_options
#       { :reference => 'Ocean Avenue' }
#     end
# end
# 
# class FlashBaseHelpersTest < ActionController::TestCase
#   tests AddressesController
# 
#   def setup
#     super
#     @request.accept = 'application/xml'
#     @controller.stubs(:resource_url).returns("http://test.host/")
#     @controller.stubs(:collection_url).returns("http://test.host/")
#   end
# 
#   def test_success_flash_message_on_create_with_yml
#     Address.stubs(:new).returns(mock_address(:save => true))
#     post :create
#     assert_equal 'You created a new address close to <b>Ocean Avenue</b>.', flash[:success]
#   end
# 
#   def test_success_flash_message_on_create_with_namespaced_controller
#     @controller = Admin::AddressesController.new
#     @controller.stubs(:resource_url).returns("http://test.host/")
#     Address.stubs(:new).returns(mock_address(:save => true))
#     post :create
#     assert_equal 'Admin, you created a new address close to <b>Ocean Avenue</b>.', flash[:success]
#   end
# 
#   def test_failure_flash_message_on_create_with_namespaced_controller_actions
#     @controller = Admin::AddressesController.new
#     @controller.stubs(:resource_url).returns("http://test.host/")
#     Address.stubs(:new).returns(mock_address(:save => false))
#     post :create
#     assert_equal 'Admin error message.', flash[:failure]
#   end
# 
#   def test_inherited_success_flash_message_on_update_on_namespaced_controllers
#     @controller = Admin::AddressesController.new
#     @controller.stubs(:resource_url).returns("http://test.host/")
#     Address.stubs(:find).returns(mock_address(:update_attributes => true))
#     put :update
#     assert_response :success
#     assert_equal 'Nice! Address was updated with success!', flash[:success]
#   end
# 
#   def test_success_flash_message_on_update
#     Address.stubs(:find).returns(mock_address(:update_attributes => true))
#     put :update
#     assert_response :success
#     assert_equal 'Nice! Address was updated with success!', flash[:success]
#   end
# 
#   def test_failure_flash_message_on_update
#     Address.stubs(:find).returns(mock_address(:update_attributes => false, :errors => {:some => :error}))
#     put :update
#     assert_equal 'Oh no! We could not update your address!', flash[:failure]
#   end
# 
#   def test_success_flash_message_on_destroy
#     Address.stubs(:find).returns(mock_address(:destroy => true))
#     delete :destroy
#     assert_equal 'Address was successfully destroyed.', flash[:success]
#   end
# 
#   protected
#     def mock_address(stubs={})
#       @mock_address ||= stub(stubs.merge(:to_xml => "xml"))
#     end
# end
