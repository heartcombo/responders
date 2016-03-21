require 'test_helper'
require 'support/models'

if defined?(ActionController::API)
  class ApiRespondWithController < ActionController::API
    respond_to :json

    def index
      respond_with [
        Customer.new('Foo', 1),
        Customer.new('Bar', 2),
      ]
    end

    def create
      respond_with Customer.new('Foo', 1), location: 'http://test.host/'
    end
  end

  class RespondWithAPITest < ActionController::TestCase
    tests ApiRespondWithController

    def test_api_controller_without_view_rendering
      @request.accept = 'application/json'

      get :index
      assert_equal 200, @response.status
      expected = [{ name: 'Foo', id: 1 }, { name: 'Bar', id: 2 }]
      assert_equal expected.to_json, @response.body

      post :create
      assert_equal 201, @response.status
      expected = { name: 'Foo', id: 1 }
      assert_equal expected.to_json, @response.body

      errors = { name: ['invalid'] }
      Customer.any_instance.stubs(:errors).returns(errors)
      post :create
      assert_equal 422, @response.status
      expected = { errors: errors }
      assert_equal expected.to_json, @response.body
    end
  end
end
