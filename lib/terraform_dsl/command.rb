module Terraform
  # Wraps terraform command execution
  class Command
    attr_accessor :command

    def initialize(stack, command)
      @stack = stack
      @command = options_for(command)
      prepare
    end

    def env
      vars = {}
      @stack.variables.each { |k, v| vars["TF_VAR_#{k}"] = v }
      @stack.module.secrets.each do |_provider, secrets|
        secrets.each do |k, v|
          vars[k.to_s] = v
        end
      end
      vars
    end

    def execute
      Process.waitpid(spawn(env, @command, chdir: @stack.stack_dir))
      fail 'Command failed' unless $CHILD_STATUS.to_i == 0
    end

    protected

    def prepare
      FileUtils.mkdir_p(@stack.stack_dir)
      File.open(File.join(@stack.stack_dir, 'terraform.tf.json'), 'w') { |f| f.write(generate) }
    end

    def options_for(cmd)
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

      "terraform #{cmd} #{options}"
    end

    def generate
      @stack.module.generate
    end
  end
end
