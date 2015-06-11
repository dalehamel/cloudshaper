require 'cloudshaper/secrets'
require 'cloudshaper/stack_element'

module Cloudshaper
  # Implements DSL for a terraform provider, and a means of loading secrets.
  class Provider < StackElement
    def load_secrets(name)
      @secrets ||= {}
      if SECRETS.has_key? name.to_sym
        @secrets[name.to_sym] = SECRETS[name.to_sym]
      end
      @secrets
    end
  end
end
