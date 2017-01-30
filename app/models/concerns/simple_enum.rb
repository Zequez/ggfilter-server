module SimpleEnum
  extend ActiveSupport::Concern

  module ClassMethods
    def simple_enum_column(column_name, values)
      define_singleton_method(:"#{column_name}_enum"){ values }
      define_method(:"#{column_name}_enum"){ values }
      define_method(:"#{column_name}=") do |val|
        val = values.keys.first if val.nil?
        write_attribute column_name, values[val.to_sym]
      end
      define_method(column_name) do
        values.invert[read_attribute column_name]
      end
    end
  end
end
