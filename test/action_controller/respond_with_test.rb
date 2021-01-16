# frozen_string_literal: true

require "test_helper"
require "support/models"

class RespondWithController < ApplicationController
  class CustomerWithJson < Customer
    def to_json(*); super; end
  end

  respond_to :html, :json, :touch
  respond_to :xml, except: :using_resource_with_block
  respond_to :js,  only: [ :using_resource_with_block, :using_resource, "using_hash_resource" ]

  def using_resource
    respond_with(resource)
  end

  def using_hash_resource
    respond_with(result: resource)
  end

  def using_resource_with_block
    respond_with(resource) do |format|
      format.csv { render body: "CSV", content_type: "text/csv" }
    end
  end

  def using_resource_with_overwrite_block
    respond_with(resource) do |format|
      format.html { render html: "HTML" }
    end
  end

  def using_resource_with_collection
    respond_with([resource, Customer.new("jamis", 9)])
  end

  def using_resource_with_parent
    respond_with(Quiz::Store.new("developer?", 11), Customer.new("david", 13))
  end

  def using_resource_with_status_and_location
    respond_with(resource, location: "http://test.host/", status: :created)
  end

  def using_resource_with_json
    respond_with(CustomerWithJson.new("david", request.delete? ? nil : 13))
  end

  def using_invalid_resource_with_template
    respond_with(resource)
  end

  def using_options_with_template
    @customer = resource
    respond_with(@customer, status: 123, location: "http://test.host/")
  end

  def using_resource_with_responder
    responder = proc { |c, r, o| c.render body: "Resource name is #{r.first.name}" }
    respond_with(resource, responder: responder)
  end

  def using_resource_with_action
    respond_with(resource, action: :foo) do |format|
      format.html { raise ActionView::MissingTemplate.new([], "bar", ["foo"], {}, false) }
    end
  end

  def using_resource_with_rendering_options
    rendering_options = { template: "addresses/edit", status: :unprocessable_entity }
    respond_with(resource, render: rendering_options) do |format|
      format.html { raise ActionView::MissingTemplate.new([], "bar", ["foo"], {}, false) }
    end
  end

  def using_responder_with_respond
    responder = Class.new(ActionController::Responder) do
      def respond; @controller.render body: "respond #{format}"; end
    end
    respond_with(resource, responder: responder)
  end

  def respond_with_additional_params
    @params = RespondWithController.params
    respond_with({ result: resource }, @params)
  end

protected

  def self.params
    {
        foo: "bar"
    }
  end

  def resource
    Customer.new("david", request.delete? ? nil : 13)
  end
end

class InheritedRespondWithController < RespondWithController
  clear_respond_to
  respond_to :xml, :json

  def index
    respond_with(resource) do |format|
      format.json { render body: "JSON" }
    end
  end
end

class CsvRespondWithController < ApplicationController
  respond_to :csv

  class RespondWithCsv
    def to_csv
      "c,s,v"
    end
  end

  def index
    respond_with(RespondWithCsv.new)
  end
end

class EmptyRespondWithController < ApplicationController
  clear_respond_to
  def index
    respond_with(Customer.new("david", 13))
  end
end

class RespondWithControllerTest < ActionController::TestCase
  def setup
    super
    @request.host = "www.example.com"
    Mime::Type.register_alias("text/html", :iphone)
    Mime::Type.register_alias("text/html", :touch)
    Mime::Type.register("text/x-mobile", :mobile)
  end

  def teardown
    super
    Mime::Type.unregister(:iphone)
    Mime::Type.unregister(:touch)
    Mime::Type.unregister(:mobile)
  end

  def test_respond_with_shouldnt_modify_original_hash
    get :respond_with_additional_params
    assert_equal RespondWithController.params, assigns(:params)
  end

  def test_using_resource
    @request.accept = "application/xml"
    get :using_resource
    assert_equal "application/xml", @response.media_type
    assert_equal "<name>david</name>", @response.body

    @request.accept = "application/json"
    get :using_resource
    assert_equal "application/json", @response.media_type
    assert_equal "{\"name\":\"david\",\"id\":13}", @response.body
  end

  def test_using_resource_with_js_simply_tries_to_render_the_template
    @request.accept = "text/javascript"
    get :using_resource
    assert_equal "text/javascript", @response.media_type
    assert_equal "alert(\"Hi\");", @response.body
  end

  def test_using_hash_resource_with_js_raises_an_error_if_template_cant_be_found
    @request.accept = "text/javascript"
    assert_raise ActionView::MissingTemplate do
      get :using_hash_resource
    end
  end

  def test_using_hash_resource
    @request.accept = "application/xml"
    get :using_hash_resource
    assert_equal "application/xml", @response.media_type
    assert_equal "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<hash>\n  <name>david</name>\n</hash>\n", @response.body

    @request.accept = "application/json"
    get :using_hash_resource
    assert_equal "application/json", @response.media_type
    assert_includes @response.body, "result"
    assert_includes @response.body, '"name":"david"'
    assert_includes @response.body, '"id":13'
  end

  def test_using_hash_resource_with_post
    @request.accept = "application/json"
    assert_raise ArgumentError, "Nil location provided. Can't build URI." do
      post :using_hash_resource
    end
  end

  def test_using_resource_with_block
    @request.accept = "*/*"
    get :using_resource_with_block
    assert_equal "text/html", @response.media_type
    assert_equal "Hello world!", @response.body

    @request.accept = "text/csv"
    get :using_resource_with_block
    assert_equal "text/csv", @response.media_type
    assert_equal "CSV", @response.body

    @request.accept = "application/xml"
    get :using_resource
    assert_equal "application/xml", @response.media_type
    assert_equal "<name>david</name>", @response.body
  end

  def test_using_resource_with_overwrite_block
    get :using_resource_with_overwrite_block
    assert_equal "text/html", @response.media_type
    assert_equal "HTML", @response.body
  end

  def test_not_acceptable
    @request.accept = "application/xml"
    assert_raises(ActionController::UnknownFormat) do
      get :using_resource_with_block
    end

    @request.accept = "text/javascript"
    assert_raises(ActionController::UnknownFormat) do
      get :using_resource_with_overwrite_block
    end
  end

  def test_using_resource_for_post_with_html_redirects_on_success
    with_test_route_set do
      post :using_resource
      assert_equal "text/html", @response.media_type
      assert_equal 302, @response.status
      assert_equal "http://www.example.com/customers/13", @response.location
      assert @response.redirect?
    end
  end

  def test_using_resource_for_post_with_html_rerender_and_yields_unprocessable_entity_on_failure
    with_test_route_set do
      errors = { name: :invalid }
      Customer.any_instance.stubs(:errors).returns(errors)
      post :using_resource
      assert_equal "text/html", @response.media_type
      assert_equal 422, @response.status
      assert_equal "New world!\n", @response.body
      assert_nil @response.location
    end
  end

  def test_using_resource_for_post_with_xml_yields_created_on_success
    with_test_route_set do
      @request.accept = "application/xml"
      post :using_resource
      assert_equal "application/xml", @response.media_type
      assert_equal 201, @response.status
      assert_equal "<name>david</name>", @response.body
      assert_equal "http://www.example.com/customers/13", @response.location
    end
  end

  def test_using_resource_for_post_with_xml_yields_unprocessable_entity_on_failure
    with_test_route_set do
      @request.accept = "application/xml"
      errors = { name: :invalid }
      Customer.any_instance.stubs(:errors).returns(errors)
      post :using_resource
      assert_equal "application/xml", @response.media_type
      assert_equal 422, @response.status
      assert_equal errors.to_xml, @response.body
      assert_nil @response.location
    end
  end

  def test_using_resource_for_post_with_json_yields_unprocessable_entity_on_failure
    with_test_route_set do
      @request.accept = "application/json"
      errors = { name: :invalid }
      Customer.any_instance.stubs(:errors).returns(errors)
      post :using_resource
      assert_equal "application/json", @response.media_type
      assert_equal 422, @response.status
      errors = { errors: errors }
      assert_equal errors.to_json, @response.body
      assert_nil @response.location
    end
  end

  def test_using_resource_for_patch_with_html_redirects_on_success
    with_test_route_set do
      patch :using_resource
      assert_equal "text/html", @response.media_type
      assert_equal 302, @response.status
      assert_equal "http://www.example.com/customers/13", @response.location
      assert @response.redirect?
    end
  end

  def test_using_resource_for_patch_with_html_rerender_and_yields_unprocessable_entity_on_failure
    with_test_route_set do
      errors = { name: :invalid }
      Customer.any_instance.stubs(:errors).returns(errors)
      patch :using_resource
      assert_equal "text/html", @response.media_type
      assert_equal 422, @response.status
      assert_equal "Edit world!\n", @response.body
      assert_nil @response.location
    end
  end

  def test_using_resource_for_patch_with_html_rerender_and_yields_unprocessable_entity_on_failure_even_on_method_override
    with_test_route_set do
      errors = { name: :invalid }
      Customer.any_instance.stubs(:errors).returns(errors)
      @request.env["rack.methodoverride.original_method"] = "POST"
      patch :using_resource
      assert_equal "text/html", @response.media_type
      assert_equal 422, @response.status
      assert_equal "Edit world!\n", @response.body
      assert_nil @response.location
    end
  end

  def test_using_resource_for_put_with_html_redirects_on_success
    with_test_route_set do
      put :using_resource
      assert_equal "text/html", @response.media_type
      assert_equal 302, @response.status
      assert_equal "http://www.example.com/customers/13", @response.location
      assert @response.redirect?
    end
  end

  def test_using_resource_for_put_with_html_rerender_and_yields_unprocessable_entity_on_failure
    with_test_route_set do
      errors = { name: :invalid }
      Customer.any_instance.stubs(:errors).returns(errors)
      put :using_resource

      assert_equal "text/html", @response.media_type
      assert_equal 422, @response.status
      assert_equal "Edit world!\n", @response.body
      assert_nil @response.location
    end
  end

  def test_using_resource_for_put_with_html_rerender_and_yields_unprocessable_entity_on_failure_even_on_method_override
    with_test_route_set do
      errors = { name: :invalid }
      Customer.any_instance.stubs(:errors).returns(errors)
      @request.env["rack.methodoverride.original_method"] = "POST"
      put :using_resource
      assert_equal "text/html", @response.media_type
      assert_equal 422, @response.status
      assert_equal "Edit world!\n", @response.body
      assert_nil @response.location
    end
  end

  def test_using_resource_for_put_with_xml_yields_no_content_on_success
    @request.accept = "application/xml"
    put :using_resource
    assert_equal 204, @response.status
    assert_equal "", @response.body
  end

  def test_using_resource_for_put_with_json_yields_no_content_on_success
    @request.accept = "application/json"
    put :using_resource_with_json
    assert_equal 204, @response.status
    assert_equal "", @response.body
  end

  def test_using_resource_for_put_with_xml_yields_unprocessable_entity_on_failure
    @request.accept = "application/xml"
    errors = { name: :invalid }
    Customer.any_instance.stubs(:errors).returns(errors)
    put :using_resource
    assert_equal "application/xml", @response.media_type
    assert_equal 422, @response.status
    assert_equal errors.to_xml, @response.body
    assert_nil @response.location
  end

  def test_using_resource_for_put_with_json_yields_unprocessable_entity_on_failure
    @request.accept = "application/json"
    errors = { name: :invalid }
    Customer.any_instance.stubs(:errors).returns(errors)
    put :using_resource
    assert_equal "application/json", @response.media_type
    assert_equal 422, @response.status
    errors = { errors: errors }
    assert_equal errors.to_json, @response.body
    assert_nil @response.location
  end

  def test_using_resource_for_delete_with_html_redirects_on_success
    with_test_route_set do
      Customer.any_instance.stubs(:destroyed?).returns(true)
      delete :using_resource
      assert_equal "text/html", @response.media_type
      assert_equal 302, @response.status
      assert_equal "http://www.example.com/customers", @response.location
    end
  end

  def test_using_resource_for_delete_with_xml_yields_no_content_on_success
    Customer.any_instance.stubs(:destroyed?).returns(true)
    @request.accept = "application/xml"
    delete :using_resource
    assert_equal 204, @response.status
    assert_equal "", @response.body
  end

  def test_using_resource_for_delete_with_json_yields_no_content_on_success
    Customer.any_instance.stubs(:destroyed?).returns(true)
    @request.accept = "application/json"
    delete :using_resource_with_json
    assert_equal 204, @response.status
    assert_equal "", @response.body
  end

  def test_using_resource_for_delete_with_html_redirects_on_failure
    with_test_route_set do
      errors = { name: :invalid }
      Customer.any_instance.stubs(:errors).returns(errors)
      Customer.any_instance.stubs(:destroyed?).returns(false)
      delete :using_resource
      assert_equal "text/html", @response.media_type
      assert_equal 302, @response.status
      assert_equal "http://www.example.com/customers", @response.location
    end
  end

  def test_using_resource_with_parent_for_get
    @request.accept = "application/xml"
    get :using_resource_with_parent
    assert_equal "application/xml", @response.media_type
    assert_equal 200, @response.status
    assert_equal "<name>david</name>", @response.body
  end

  def test_using_resource_with_parent_for_post
    with_test_route_set do
      @request.accept = "application/xml"

      post :using_resource_with_parent
      assert_equal "application/xml", @response.media_type
      assert_equal 201, @response.status
      assert_equal "<name>david</name>", @response.body
      assert_equal "http://www.example.com/quiz_stores/11/customers/13", @response.location

      errors = { name: :invalid }
      Customer.any_instance.stubs(:errors).returns(errors)
      post :using_resource
      assert_equal "application/xml", @response.media_type
      assert_equal 422, @response.status
      assert_equal errors.to_xml, @response.body
      assert_nil @response.location
    end
  end

  def test_using_resource_with_collection
    @request.accept = "application/xml"
    get :using_resource_with_collection
    assert_equal "application/xml", @response.media_type
    assert_equal 200, @response.status
    assert_match(/<name>david<\/name>/, @response.body)
    assert_match(/<name>jamis<\/name>/, @response.body)
  end

  def test_using_resource_with_action
    @controller.instance_eval do
      def render(params = {})
        self.response_body = "#{params[:action]} - #{formats}"
      end
    end

    errors = { name: :invalid }
    Customer.any_instance.stubs(:errors).returns(errors)

    post :using_resource_with_action
    assert_equal "foo - #{[:html]}", @controller.response.body
  end

  def test_using_resource_with_rendering_options
    Customer.any_instance.stubs(:errors).returns(name: :invalid)

    post :using_resource_with_rendering_options

    assert_response :unprocessable_entity
    assert_equal "edit.html.erb", @controller.response.body
  end

  def test_respond_as_responder_entry_point
    @request.accept = "text/html"
    get :using_responder_with_respond
    assert_equal "respond html", @response.body

    @request.accept = "application/xml"
    get :using_responder_with_respond
    assert_equal "respond xml", @response.body
  end

  def test_clear_respond_to
    @controller = InheritedRespondWithController.new
    @request.accept = "text/html"
    assert_raises(ActionController::UnknownFormat) do
      get :index
    end
  end

  def test_first_in_respond_to_has_higher_priority
    @controller = InheritedRespondWithController.new
    @request.accept = "*/*"
    get :index
    assert_equal "application/xml", @response.media_type
    assert_equal "<name>david</name>", @response.body
  end

  def test_block_inside_respond_with_is_rendered
    @controller = InheritedRespondWithController.new
    @request.accept = "application/json"
    get :index
    assert_equal "JSON", @response.body
  end

  def test_no_double_render_is_raised
    @request.accept = "text/html"
    assert_raise ActionView::MissingTemplate do
      get :using_resource
    end
  end

  def test_using_resource_with_status_and_location
    @request.accept = "text/html"
    post :using_resource_with_status_and_location
    assert @response.redirect?
    assert_equal "http://test.host/", @response.location

    @request.accept = "application/xml"
    get :using_resource_with_status_and_location
    assert_equal 201, @response.status
  end

  def test_using_resource_with_status_and_location_with_invalid_resource
    errors = { name: :invalid }
    Customer.any_instance.stubs(:errors).returns(errors)

    @request.accept = "text/xml"

    post :using_resource_with_status_and_location
    assert_equal errors.to_xml, @response.body
    assert_equal 422, @response.status
    assert_nil @response.location

    put :using_resource_with_status_and_location
    assert_equal errors.to_xml, @response.body
    assert_equal 422, @response.status
    assert_nil @response.location
  end

  def test_using_invalid_resource_with_template
    errors = { name: :invalid }
    Customer.any_instance.stubs(:errors).returns(errors)

    @request.accept = "text/xml"

    post :using_invalid_resource_with_template
    assert_equal errors.to_xml, @response.body
    assert_equal 422, @response.status
    assert_nil @response.location

    put :using_invalid_resource_with_template
    assert_equal errors.to_xml, @response.body
    assert_equal 422, @response.status
    assert_nil @response.location
  end

  def test_using_options_with_template
    @request.accept = "text/xml"

    post :using_options_with_template
    assert_equal "<customer-name>david</customer-name>", @response.body
    assert_equal 123, @response.status
    assert_equal "http://test.host/", @response.location

    put :using_options_with_template
    assert_equal "<customer-name>david</customer-name>", @response.body
    assert_equal 123, @response.status
    assert_equal "http://test.host/", @response.location
  end

  def test_using_resource_with_responder
    get :using_resource_with_responder
    assert_equal "Resource name is david", @response.body
  end

  def test_using_resource_with_set_responder
    RespondWithController.responder = proc { |c, r, o| c.render body: "Resource name is #{r.first.name}" }
    get :using_resource
    assert_equal "Resource name is david", @response.body
  ensure
    RespondWithController.responder = ActionController::Responder
  end

  def test_raises_missing_renderer_if_an_api_behavior_with_no_renderer
    @controller = CsvRespondWithController.new
    assert_raise ActionController::MissingRenderer do
      get :index, format: "csv"
    end
  end

  def test_error_is_raised_if_no_respond_to_is_declared_and_respond_with_is_called
    @controller = EmptyRespondWithController.new
    @request.accept = "*/*"
    assert_raise RuntimeError do
      get :index
    end
  end

  private

  def with_test_route_set
    with_routing do |set|
      set.draw do
        resources :customers
        resources :quiz_stores do
          resources :customers
        end
        ActiveSupport::Deprecation.silence do
          get ":controller/:action"
        end
      end
      yield
    end
  end
end

class LocationsController < ApplicationController
  respond_to :html
  before_action :set_resource

  def create
    respond_with @resource, location: -> { "given_location" }
  end

  def update
    respond_with @resource, location: "given_location"
  end

  def set_resource
    @resource = Address.new
    @resource.errors.add(:fail, "FAIL") if params[:fail]
  end
end

class LocationResponderTest < ActionController::TestCase
  tests LocationsController

  def test_redirects_to_block_location_on_success
    post :create
    assert_redirected_to "given_location"
  end

  def test_renders_page_on_fail
    post :create, params: { fail: true }
    assert_includes @response.body, "new.html.erb"
  end

  def test_redirects_to_plain_string
    post :update
    assert_redirected_to "given_location"
  end
end
