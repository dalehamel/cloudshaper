require_relative 'stack_element'
require_relative 'stack_modules'
require_relative 'stack_module'
require_relative 'stacks'

module Terraform
  class Module < StackElement
    def initialize(parent_module, module_name, &block)
      super(parent_module, &block)

      if @fields[:source].match(/^module_/)
        build_submodule(parent_module, module_name)
      end
    end

  private

    def build_submodule(parent_module, module_name)
      generated = generate_child_module(parent_module)
      module_path = File.join(Stacks.dir, parent_module.id, module_name.to_s)
      FileUtils.mkdir_p(module_path)
      File.open(File.join(module_path, 'stack_module.tf.json'),'w') { |f| f.write(generated) }
      @fields[:source] = File.expand_path(module_path)
    end

    def generate_child_module(parent_module)
      variables = @fields.clone
      variables.delete(:source)
      variables[:terraform_stack_id] = parent_module.id
      child_name = @fields[:source].gsub(/^module_/,'')
      child_module = StackModules.get(child_name)
      child_module.build(variables)
      child_module.generate
    end
  end
end
