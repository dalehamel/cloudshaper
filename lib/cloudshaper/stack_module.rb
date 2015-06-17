require 'json'
require 'fileutils'

require 'cloudshaper/stack_modules'
require 'cloudshaper/resource'
require 'cloudshaper/provider'
require 'cloudshaper/variable'
require 'cloudshaper/module'
require 'cloudshaper/output'

module Cloudshaper
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

    attr_accessor :name, :secrets

    def initialize(name, &block)
      @name = name
      @stack_elements = { resource: {}, provider: {}, variable: {}, output: {}, module: {} }
      @secrets = {}
      @block = block
      variable(:cloudshaper_stack_id) { default '' }
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

    def id
      get(:cloudshaper_stack_id)
    end

    def get(variable)
      elements[:variable].fetch(variable)[:default]
    end

    def each_variable(&b)
      elements[:variable].each(&b)
    end

    def get_resource(type, id)
      @stack_elements[:resource].fetch(type).fetch(id)
    end

    private

    def elements
      elements = @stack_elements.clone
      variables = StackModule.flatten_variable_arrays(@stack_elements[:variable])
      @stack_elements[:module].each do |mod, data|
        elements[:module][mod] = StackModule.flatten_variable_arrays(data)
      end
      elements[:variable] = variables
      elements
    end

    def register_resource(resource_type, name, &block)
      @stack_elements[:resource] ||= {}
      @stack_elements[:resource][resource_type.to_sym] ||= {}
      @stack_elements[:resource][resource_type.to_sym][name.to_sym] = Cloudshaper::Resource.new(self, name, resource_type, &block).fields
    end

    def register_variable(name, &block)
      return if @stack_elements[:variable].key?(name)

      new_variable = Cloudshaper::Variable.new(self, &block).fields
      if new_variable[:default].nil?
        @stack_elements[:variable][name.to_sym] = {}
      else
        @stack_elements[:variable][name.to_sym] = {
          default: new_variable[:default]
        }
      end
    end

    def register_output(name, &block)
      new_output = Cloudshaper::Output.new(self, &block).fields
      @stack_elements[:output][name.to_sym] = new_output
    end

    def register_module(name, &block)
      new_module = Cloudshaper::Module.new(self, &block).fields
      @stack_elements[:module][name.to_sym] = new_module
    end

    def register_provider(name, &block)
      provider = Cloudshaper::Provider.new(self, &block).fields
      @stack_elements[:provider][name.to_sym] = provider
    end

    alias_method :resource,  :register_resource
    alias_method :variable,  :register_variable
    alias_method :provider,  :register_provider
    alias_method :output,    :register_output
    alias_method :submodule, :register_module
  end
end
