require 'yaml'
require 'securerandom'

require 'cloudshaper/stack'

module Cloudshaper
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

      def init
        config = ENV['STACK_CONFIG'] || 'stacks.yml'
        fail "stacks.yaml already exists at #{File.expand_path(config)}" if File.exist?(config)
        File.open(config, 'w') do |f|
          f.write(YAML.dump(base_config))
        end
      end

      def base_config
        {
          'common' => {},
          'stacks' => [base_stack_config]
        }
      end

      def base_stack_config
        {
          'name' => 'SET_NAME',
          'uuid' => SecureRandom.uuid,
          'description' => 'SET_A_DESCRIPTION',
          'root' => 'SET_A_TEMPLATE',
          'variables' => {}
        }
      end

      def reset!
        @stacks ||= {}
      end

      def dir
        File.expand_path(File.join(ENV['TERRAFORM_DATA_DIR'] || 'data', 'stacks'))
      end
    end
    reset!
  end
end
