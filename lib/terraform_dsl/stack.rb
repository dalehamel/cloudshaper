require_relative 'stack_templates.rb'
require_relative 'command'

module Terraform
  # Wrapper to instantiate a stack from a yaml definition
  class Stack
    class MalformedConfig < Exception; end
    class << self
      def load(config)
        fail MalformedConfig, "Configuration malformed at #{config}" unless config.is_a?(Hash)
        fail MalformedConfig, "A name must be specified for the stack #{config}" unless config.key?('name')
        new(config)
      end
    end

    attr_reader :name, :description, :template, :variables, :stack_dir

    def initialize(config)
      @name = config['name']
      @template = StackTemplates.find(config['template'])
      @description = config['description'] || ''
      @data_dir = config['data_dir'] || 'data'
      @variables = config['variables'] || {}
      @stack_dir = File.expand_path(File.join(@data_dir, 'stacks', @name))
      @variables['terraform_stack_id'] = "terraform_#{@name}" # FIXME: append a UUID of some kind
    end

    def apply
      Command.new(self, :apply).execute
    end

    def destroy
      Command.new(self, :destroy).execute
    end

    def plan
      Command.new(self, :plan).execute
    end

    def show
      Command.new(self, :show).execute
    end

    def to_s
      <<-eos
Name: #{@name}
Description: #{@description}
Stack Directory: #{@stack_dir}
      eos
    end
  end
end
