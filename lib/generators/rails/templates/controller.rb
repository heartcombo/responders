<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
<% unless options[:singleton] -%>
  def index
    @<%= table_name %> = <%= orm_class.all(class_name) %>
    respond_with(@<%= table_name %>)
  end
<% end -%>

  def show
    @<%= file_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    respond_with(@<%= file_name %>)
  end

  def new
    @<%= file_name %> = <%= orm_class.build(class_name) %>
    respond_with(@<%= file_name %>)
  end

  def edit
    @<%= file_name %> = <%= orm_class.find(class_name, "params[:id]") %>
  end

  def create
    @<%= file_name %> = <%= orm_class.build(class_name, "params[:#{file_name}]") %>
    <%= "flash[:notice] = '#{class_name} was successfully created.' if " if flash? %>@<%= orm_instance.save %>
    respond_with(@<%= file_name %>)
  end

  def update
    @<%= file_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    <%= "flash[:notice] = '#{class_name} was successfully updated.' if " if flash? %>@<%= orm_instance.update_attributes("params[:#{file_name}]") %>
    respond_with(@<%= file_name %>)
  end

  def destroy
    @<%= file_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    @<%= orm_instance.destroy %>
    respond_with(@<%= file_name %>)
  end
end
<% end -%>