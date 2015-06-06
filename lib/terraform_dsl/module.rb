require_relative 'stack_element.rb'

module Terraform
  class Module < StackElement
    def initialize(parent_module, module_name, &block)
      #super(parent_module, &block)
      # module = StackModules.get(module_name)
      # module.build(variables)
      # module.generate
      # @fields[:source] = generated_source
      # pass variables in (method_missing trick)
    end
  end
end
