require_relative 'stacks'
require_relative 'stack_element'

module Terraform
  class Module < StackElement
    def initialize(parent_module, module_name, &block)
      super(parent_module, &block)
      variables = @fields.clone
      source = @fields[:source]
      variables.delete(:source)

      if source.match(/^module_/)
        variables[:terraform_stack_id] = parent_module.id
        module_name = source.gsub(/^module_/,'')
        child_module = StackModules.get(module_name)
        child_module.build(variables)
        generated = child_module.generate
        module_path = File.join(Stacks.dir, parent_module.id, module_name)
        FileUtils.mkdir_p(module_path)
        File.open(File.join(module_path, 'stack_module.tf.json'),'w') { |f| f.write(generated) }
        @fields[:source] = File.expand_path(module_path)
      end
    end
  end
end
