
class Customer < Struct.new(:name, :id)
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def to_xml(options={})
    if options[:builder]
      options[:builder].name name
    else
      "<name>#{name}</name>"
    end
  end

  def to_js(options={})
    "name: #{name.inspect}"
  end
  alias :to_text :to_js

  def errors
    []
  end

  def persisted?
    id.present?
  end
end

class ValidatedCustomer < Customer
  def errors
    if name =~ /Sikachu/i
      []
    else
      [{:name => "is invalid"}]
    end
  end
end

module Quiz
  class Question < Struct.new(:name, :id)
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    def persisted?
      id.present?
    end
  end

  class Store < Question
  end
end
