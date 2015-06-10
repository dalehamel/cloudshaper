require 'cloudshaper/stack_element'

module Cloudshaper
  # Defines a terraform resource
  class Resource < StackElement
    attr_reader :resource_name

    def initialize(parent_module, resource_name, resource_type, &block)
      @resource_name = resource_name
      @resource_type = resource_type
      super(parent_module, &block)

      # Allow provider specific post processing
      sym = "post_processing_#{resource_type.split('_').first}"
      send(sym) if self.respond_to?(sym, include_private: true)
    end

    # Allow provisioner blocks to be nested within resources
    def provisioner(provisioner_type, &block)
      provisioner_type = provisioner_type.to_sym

      @fields[:provisioner] = @fields[:provisioner] || []

      provisioner_set = Provisioner.new(@module, &block)
      @fields[:provisioner] << { cleanup_provisioner_type(provisioner_type) => provisioner_set.fields }
    end

    private

    def cleanup_provisioner_type(provisioner_type)
      case provisioner_type.to_sym
      when :remote_exec
        'remote-exec'
      when :local_exec
        'local-exec'
      else
        provisioner_type
      end
    end
  end
  # Defines a terraform resource provisioner
  class Provisioner < StackElement
  end
end
