require 'cloudshaper/stacks'
require 'cloudshaper/command'
require 'cloudshaper/remote'

module Cloudshaper
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

    attr_reader :name, :description, :root,
                :stack_dir, :stack_id, :remote,
                :variables

    def initialize(config)
      @name = config.fetch('name')
      @uuid = config.fetch('uuid')
      @remote = config['remote'] || {}
      @description = config['description'] || ''

      @root = config.fetch('root')
      @stack_id = "cloudshaper_#{@name}_#{@uuid}"
      @stack_dir = File.join(Stacks.dir, @stack_id)
      @variables = config['variables'] || {}
      @variables['cloudshaper_stack_id'] = @stack_id
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
