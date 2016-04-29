require 'test_helper'

class ThingsController < ApplicationController
  clear_respond_to

  respond_to :js
  respond_to :html, :only => [:show, :new]

  before_action :verify_request_format!

  attr_reader :called

  def action
    @called = true
    render :inline => action_name
  end

  alias :index :action
  alias :show :action
  alias :new :action
end

class VerifyRequestFormatTest < ActionController::TestCase
  tests ThingsController

  def test_strict_mode_shouldnt_call_action
    assert_raises(ActionController::UnknownFormat) do
      get :index
    end

    refute @controller.called, 'action should not be executed.'
  end

  def test_strict_mode_calls_action_with_right_format
    get :index, :format => :js

    assert @controller.called, 'action should be executed.'
  end

  def test_strict_mode_respects_only_option
    get :show, :format => :html

    assert @controller.called, 'action should be executed.'
  end
end
