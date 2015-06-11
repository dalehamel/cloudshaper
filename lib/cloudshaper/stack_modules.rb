module Cloudshaper
  # Stack module factory, register a module and provide clones of it
  class StackModules
    class ModuleNotFound < StandardError; end
    class ModuleAlreadyRegistered < StandardError; end

    class << self
      def register(name, stack_module)
        fail ModuleAlreadyRegistered, "#{name} is already a registered stack_module" if @stack_modules.key?(name.downcase)
        @stack_modules[name.downcase] = stack_module
      end

      def get(stack_module_name)
        fail ModuleNotFound, "#{stack_module_name} module module not found" unless @stack_modules.key?(stack_module_name.downcase)
        @stack_modules[stack_module_name.downcase].clone
      end

      def reset!
        @stack_modules = {}
      end
    end
    reset!
  end
end
