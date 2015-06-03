require 'json'
require 'fileutils'

require_relative 'stack_templates.rb'
require_relative 'resource.rb'
require_relative 'provider.rb'
require_relative 'variable.rb'

module Terraform
  # Wrapper for DSL to provide a templated stack
  class StackTemplate
    # Templated variables with optional default values
    class VariableDefinition
      attr_reader :name, :default

      def initialize(name, default: nil)
        @name, @default = name, default
      end

      def as_json(_options = {})
        {
          name: @name,
          default: @default
        }
      end
    end

    class << self
      attr_accessor :stack_elements, :variable_definitions, :secrets

      def register_resource(resource_type, name, &block)
        @stack_elements[:resource] ||= {}
        @stack_elements[:resource][resource_type.to_sym] ||= {}
        @stack_elements[:resource][resource_type.to_sym][name.to_sym] = Terraform::Resource.new(name, resource_type, &block).fields
      end

      def register_variable(name, &block)
        new_variable = Terraform::Variable.new(&block).fields
        @stack_elements[:variable][name.to_sym] = new_variable
        @variable_definitions[name.to_sym] = VariableDefinition.new(name, default: new_variable[:default])
      end

      def register_provider(name, &block)
        provider = Terraform::Provider.new(&block)
        @secrets.merge!(provider.load_secrets(name))
        @stack_elements[:provider][name.to_sym] = provider.fields
      end

      def reset!
        @stack_elements = { resource: {}, provider: {}, variable: {} }
        @variable_definitions = {}
        @secrets = {}
        variable(:terraform_stack_id) {}
      end

      def inherited(subclass)
        StackTemplates.register(subclass)
        subclass.reset!
        super
      end

      def generate
        JSON.pretty_generate(@stack_elements)
      end

      def variables
        @variables ||= begin
          hash = {}

          variable_definitions.each do |name, definition|
            hash[name] = definition.default
          end
          hash
        end
      end

      alias_method :resource, :register_resource
      alias_method :variable, :register_variable
      alias_method :provider, :register_provider
    end

    reset!
  end
end
