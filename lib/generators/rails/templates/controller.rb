<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  before_action :set_<%= singular_table_name %>, only: [:show, :edit, :update, :destroy]

  def index
    @<%= plural_table_name %> = <%= class_name %>.all
    respond_with(@<%= plural_table_name %>)
  end

  def show
    respond_with(@<%= singular_table_name %>)
  end

  def new
    @<%= singular_table_name %> = <%= class_name %>.build
    respond_with(@<%= singular_table_name %>)
  end

  def edit
  end

  def create
    @<%= singular_table_name %> = <%= class_name %>.create(<%= singular_table_name %>_params)
    respond_with(@<%= singular_table_name %>)
  end

  def update
    @<%= singular_table_name %>.update(<%= singular_table_name %>_params)
    respond_with(@<%= singular_table_name %>)
  end

  def destroy
    @<%= singular_table_name %>.destroy
    respond_with(@<%= singular_table_name %>)
  end

  private
    def set_<%= singular_table_name %>
      @<%= singular_table_name %> = <%= class_name %>.find(params[:id])
    end

    def <%= "#{singular_table_name}_params" %>
      <%- if attributes_names.empty? -%>
      params[:<%= singular_table_name %>]
      <%- else -%>
      params.require(:<%= singular_table_name %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
      <%- end -%>
    end
end
<% end -%>