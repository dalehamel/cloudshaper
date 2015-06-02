require 'yaml'

require_relative 'stack_templates.rb'

module Terraform
  # Wrapper to instantiate a stack from a yaml definition
  class Stack
    class << self
      def load(payload)
        return unless payload.present?
        config = YAML.load(payload)
        new(config)
      end
    end

    attr_reader :name, :description, :template, :variables

    def initialize(config)
      @name = config['name'] || '' # should raise an if there's no name
      @template = StackTemplates.find(config['template'])
      @description = config['description'] || ''
      @data_dir = config['work_dir'] || File.join(File.expand_path(File.dirname(__FILE__)), 'data')
      @variables = config['variables'] || {}
      @stack_dir = File.join(@data_dir, 'stacks', @name)
    end

    def terraform(cmd)
      options = begin
        case cmd
        when :apply
          '-input=false'
        when :destroy
          '-input=false -force'
        when :plan
          '-input=false'
        when :graph
          '-draw-cycles'
        else
          ''
        end
      end

      "#{env.join(' ')} terraform #{cmd} #{options}"
    end

    def apply
      stack_data = self.class.generate
      File.open(File.join(@data_dir, "#{@stack.name}.tf.json"), 'w') { |f| f.write(stack_data) }
      terraform(:apply)
    end

    def destroy
      terraform(:destroy)
    end
  end
end
