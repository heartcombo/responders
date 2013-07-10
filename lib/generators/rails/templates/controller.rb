<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  <%= controller_before_filter %> :set_<%= file_name %>, only: [:show, :edit, :update, :destroy]

<% unless options[:singleton] -%>
  def index
    @<%= table_name %> = <%= orm_class.all(class_name) %>
    respond_with(@<%= table_name %>)
  end
<% end -%>

  def show
    respond_with(@<%= file_name %>)
  end

  def new
    @<%= file_name %> = <%= orm_class.build(class_name) %>
    respond_with(@<%= file_name %>)
  end

  def edit
  end

  def create
    @<%= file_name %> = <%= orm_class.build(class_name, attributes_params) %>
    <%= "flash[:notice] = '#{class_name} was successfully created.' if " if flash? %>@<%= orm_instance.save %>
    respond_with(@<%= file_name %>)
  end

  def update
    <%= "flash[:notice] = '#{class_name} was successfully updated.' if " if flash? %>@<%= orm_instance_update(attributes_params) %>
    respond_with(@<%= file_name %>)
  end

  def destroy
    @<%= orm_instance.destroy %>
    respond_with(@<%= file_name %>)
  end

  private
    def set_<%= file_name %>
      @<%= file_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    end
    <%- if strong_parameters_defined? -%>

    def <%= "#{file_name}_params" %>
      <%- if attributes_names.empty? -%>
      params[:<%= file_name %>]
      <%- else -%>
      params.require(:<%= file_name %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
      <%- end -%>
    end
    <%- end -%>
end
<% end -%>
