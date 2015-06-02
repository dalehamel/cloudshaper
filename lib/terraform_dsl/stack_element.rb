module Terraform
  class StackElement
    attr_reader :fields

    def initialize(&block)
      @fields = {}
      instance_eval &block
    end

  private

    # Allows resource attributes to be specified with a nice syntax
    # If the method is implemented, it will be treated as a nested resource
    def method_missing(method_name, *args, &block)
      symbol = method_name.to_sym
      if args.length == 1
        if args[0] == nil
          raise "Passed nil to '#{method_name}'. Generally disallowed, subclass StackElement if you need this."
        end
        add_field(symbol, args[0])
      else
        add_field(symbol, Terraform::StackElement.new(&block).fields)
      end
    end

    # Reference a variable
    def var(variable_name)
      "${var.#{variable_name}}"
    end

    # Syntax to handle interpolation of resource variables
    def value_of(resource_type, resource_name, value_type)
      "${#{resource_type}.#{resource_name}.#{value_type}}"
    end

    # Shorthand to interpolate the ID of another resource
    def id_of(resource_type, resource_name)
      value_of(resource_type, resource_name, :id)
    end

    def add_field(symbol, value)
      if existing = @fields[symbol]
        # If it's already an array, just push to it
        unless existing.is_a?(Array)
          @fields[symbol] = [ existing ]
        end
        @fields[symbol] << value
      else
        @fields[symbol] = value
      end
    end
  end
end
