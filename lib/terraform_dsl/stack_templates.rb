
module Terraform
  class StackTemplates
    class StackNotFound < StandardError; end
    class << self
      def register(template)
        @stack_templates[template.name] = template
      end

      def find(template_name)
        fail "#{template_name} stack template note found" unless @stack.templates.key?(template_name.downcase)
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
