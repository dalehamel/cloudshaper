require_relative 'stacks'
require_relative 'stack_modules'
require_relative 'command'
require_relative 'remote'

module Terraform
  # Wrapper to instantiate a stack from a yaml definition
  class Stack
    class MalformedConfig < Exception; end
    class << self
      def load(config)
        fail MalformedConfig, "Configuration malformed at #{config}" unless config.is_a?(Hash)
        fail MalformedConfig, "A name must be specified for the stack #{config}" unless config.key?('name')
        fail MalformedConfig, 'You must specify a uuid. Get one from rake uuid and add it to the config' unless config.key?('uuid')
        new(config)
      end
    end

    attr_reader :name, :description, :module, :stack_dir,
                :variables, :stack_id, :remote

    def initialize(config)
      @name = config['name']
      @uuid = config['uuid']
      @description = config['description'] || ''
      @variables = config['variables'] || {}
      @remote = config['remote'] || {}
      @stack_id = "terraform_#{@name}_#{@uuid}"
      @module = StackModules.get(config['root'])
      @variables['terraform_stack_id'] = @stack_id
      @stack_dir = File.join(Stacks.dir, @stack_id)
      @module.build(@variables.map { |k, v| [k.to_sym, v] }.to_h)
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

    def get
      Command.new(self, :get).execute
    end

    def show
      Command.new(self, :show).execute
    end

    def pull
      Remote.new(self, :pull).execute
    end

    def push
      Remote.new(self, :pull).execute
    end

    def remote_config
      Remote.new(self, :config).execute
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
