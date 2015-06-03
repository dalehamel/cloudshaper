require 'yaml'

require_relative 'stack.rb'

module Terraform
  # Singleton to keep track of stack templates
  class Stacks
    class MalformedConfig < StandardError; end
    class << self
      attr_reader :stacks

      def load
        config = ENV['STACK_CONFIG'] || 'stacks.yml'
        fail 'stacks.yml must exist in root directory, or specify STACK_CONFIG pointing to stacks.yml' unless File.exist?(config)
        stack_specs = YAML.load(File.read(config))
        fail MalformedConfig, 'Stacks must be an array' unless stack_specs.key?('stacks') && stack_specs['stacks'].is_a?(Array)
        common = stack_specs['common'] || {}
        stack_specs['stacks'].each do |stack_spec|
          stack = Stack.load(stack_spec.merge(common))
          @stacks[stack.name] = stack
        end
      end

      def reset!
        @stacks ||= {}
      end
    end
    reset!
  end
end
