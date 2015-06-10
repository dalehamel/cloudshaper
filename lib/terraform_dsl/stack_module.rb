require 'json'
require 'fileutils'

require_relative 'stack_modules.rb'
require_relative 'resource.rb'
require_relative 'provider.rb'
require_relative 'variable.rb'
require_relative 'module.rb'
require_relative 'output.rb'

module Terraform
  # Stack Modules contain stack elements. A stack is made up of a root module, which may have submodules
  class StackModule
    class << self
      def define(name, &block)
        template = new(name, &block)
        StackModules.register(name, template)
      end

      def flatten_variable_arrays(variables)
        vars = variables.map do |k, v|
          if v.is_a?(Hash) && v.key?(:default) && v[:default].is_a?(Array)
            v[:default] = v[:default].join(',')
          elsif v.is_a?(Array)
            v = v.join(',')
          end
          [k, v]
        end
        Hash[vars]
      end
    end

    attr_accessor :secrets

    def initialize(_name, &block)
      @stack_elements = { resource: {}, provider: {}, variable: {}, output: {}, module: {} }
      @secrets = {}
      @block = block
      variable(:terraform_stack_id) {}
    end

    def clone
      b = @block
      StackModule.new(@name, &b)
    end

    def build(**kwargs)
      vars = Hash[kwargs.map { |k, v| [k, { default: v }] }]
      @stack_elements[:variable].merge!(vars)
      b = @block
      instance_eval(&b)
    end

    def generate
      JSON.pretty_generate(elements)
    end

    def variables
      elements[:variable]
    end

    def outputs
      @stack_elements[:output]
    end

    def get(variable)
      @stack_elements[:variable].fetch(variable)[:default]
    end

    def elements
      elements = @stack_elements.clone
      variables = StackModule.flatten_variable_arrays(@stack_elements[:variable])
      @stack_elements[:module].each do |mod, data|
        elements[:module][mod] = StackModule.flatten_variable_arrays(data)
      end
      elements[:variable] = variables
      elements
    end

    def id
      get(:terraform_stack_id)
    end

    private

    def register_resource(resource_type, name, &block)
      @stack_elements[:resource] ||= {}
      @stack_elements[:resource][resource_type.to_sym] ||= {}
      @stack_elements[:resource][resource_type.to_sym][name.to_sym] = Terraform::Resource.new(self, name, resource_type, &block).fields
    end

    def register_variable(name, &block)
      new_variable = Terraform::Variable.new(self, &block).fields
      unless @stack_elements[:variable].key?(name.to_sym)
        @stack_elements[:variable][name.to_sym] = { default: new_variable[:default] || '' }
      end
    end

    def register_output(name, &block)
      new_output = Terraform::Output.new(self, &block).fields
      @stack_elements[:output][name.to_sym] = new_output
    end

    def register_module(name, &block)
      new_module = Terraform::Module.new(self, name, &block).fields
      @stack_elements[:module][name.to_sym] = new_module
    end

    def register_provider(name, &block)
      provider = Terraform::Provider.new(self, &block)
      @secrets.merge!(provider.load_secrets(name))
      @stack_elements[:provider][name.to_sym] = provider.fields
    end

    alias_method :resource, :register_resource
    alias_method :variable, :register_variable
    alias_method :provider, :register_provider
    alias_method :output,   :register_output
    alias_method :submodule,    :register_module
  end
end
