require_relative 'stack_templates.rb'

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

    attr_reader :name, :description, :template, :variables

    def initialize(config)
      @name = config['name']
      @template = StackTemplates.find(config['template'])
      @description = config['description'] || ''
      @data_dir = config['data_dir'] || 'data'
      @variables = config['variables'] || {}
      @stack_dir = File.expand_path(File.join(@data_dir, 'stacks', @name))
    end

    def apply
      terraform(:apply)
    end

    def destroy
      terraform(:destroy)
    end

    def plan
      terraform(:plan)
    end

    def show
      terraform(:show)
    end

    def to_s
      <<-eos
Name: #{@name}
Description: #{@description}
Stack Directory: #{@stack_dir}
      eos
    end

    private

    def prepare
      FileUtils.mkdir_p(@stack_dir)
      File.open(File.join(@stack_dir, 'terraform.tf.json'), 'w') { |f| f.write(generate) }
    end

    def terraform(cmd)
      prepare
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

      command("terraform #{cmd} #{options}")
    end

    def generate
      @template.generate
    end

    def env
      vars = {}
      @variables.each { |k, v| vars["TF_VAR_#{k}"] = v }
      vars
    end

    def command(cmd)
      Process.waitpid(spawn(env, cmd, chdir: @stack_dir))
      fail 'Command failed' unless $CHILD_STATUS.to_i == 0
    end
  end
end
