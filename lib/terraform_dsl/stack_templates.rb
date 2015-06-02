module Terraform
  # Singleton to keep track of stack templates
  class StackTemplates
    class StackNotFound < StandardError; end
    class StackAlreadyRegistered < StandardError; end

    class << self
      def register(template)
        fail StackAlreadyRegistered, "#{template.name} is already a registered template" if @stack_templates.key?(template.name.downcase)
        @stack_templates[template.name.downcase] = template
      end

      def find(template_name)
        fail StackNotFound, "#{template_name} stack template not found" unless @stack_templates.key?(template_name.downcase)
        @stack_templates[template_name.downcase]
      end

      def all
        @stack_templates.keys
      end

      def reset!
        @stack_templates ||= {}
      end
    end
    reset!
  end
end
