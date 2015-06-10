require 'cloudshaper/secrets'
require 'cloudshaper/stack_element'

module Cloudshaper
  # Implements DSL for a terraform provider, and a means of loading secrets.
  class Provider < StackElement
    def load_secrets(name)
      @secrets ||= {}
      @secrets[name.to_sym] = SECRETS[name.to_sym]
      @secrets
    end
  end
end
