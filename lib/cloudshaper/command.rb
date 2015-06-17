require 'cloudshaper/secrets'

module Cloudshaper
  # Wraps terraform command execution
  class Command
    attr_accessor :command

    def initialize(stack, command)
      @stack = stack
      @command = options_for(command)
    end

    # fixme - make these shell safe
    def env
      vars = {}
      @stack.variables.each { |k, v| vars["TF_VAR_#{k}"] = v }
      SECRETS.each do |_provider, secrets|
        if secrets.is_a?(Hash)
          secrets.each do |k, v|
            vars[k.to_s] = v
          end
        end
      end
      vars
    end

    def execute
      Process.waitpid(spawn(env, @command))
      fail 'Command failed' unless $CHILD_STATUS.to_i == 0
    end

    protected

    def options_for(cmd)
      options = begin
        case cmd
        when :apply
          '-input=false'
        when :destroy
          '-input=false -force'
        when :plan
          '-input=false -module-depth=-1'
        when :graph
          '-draw-cycles'
        else
          ''
        end
      end

      "terraform #{cmd} #{options} #{@stack.root}"
    end
  end
end
