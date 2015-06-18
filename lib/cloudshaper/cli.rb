require 'thor'
require 'cloudshaper'

module Cloudshaper
  class CLI < Thor
    class_option 'remote_state', type: 'boolean'

    desc 'list', 'List all available stacks'
    def list
      Cloudshaper::Stacks.stacks.each do |name, _stack|
        puts name
      end
    end

    desc 'show NAME', 'Show details about a stack by name'
    def show(name)
      stack = load_stack(name, options)
      puts stack
    end

    desc 'plan NAME', 'Show pending changes for a stack'
    def plan(name)
      stack = load_stack(name, options)
      remote_config(name) if remote_state?
      stack.plan
    end

    desc 'apply NAME', 'Apply all pending stack changes'
    def apply(name)
      stack = load_stack(name, options)
      stack.apply
      push(name) if remote_state?
    end

    desc 'destroy NAME', 'Destroy a stack'
    def destroy(name)
      stack = load_stack(name, options)
      stack.destroy
      push(name) if remote_state?
    end

    desc 'pull NAME', 'Pull stack state from remote location'
    def pull(name)
      stack = load_stack(name, options, false)
      remote_config(name)
      stack.pull
    end

    desc 'push NAME', 'Push stack state from remote location'
    def push(name)
      stack = load_stack(name, options)
      remote_config(name)
      stack.push
    end

    desc 'remote_config NAME', 'Sets up remote config for a stack'
    def remote_config(name)
      stack = load_stack(name, options, false)
      stack.remote_config
    end

    desc 'init', 'Initialize stacks.yml if it does not exist'
    def init
      Cloudshaper::Stacks.init
      puts "Created stacks.yml, you're ready to configure your stack"
    end

    desc 'uuid', "Generate a UUID for your stacks, so they don't clobber each other"
    def uuid
      puts SecureRandom.uuid
    end

    desc 'version', 'Prints the version of cloudshaper'
    def version
      puts Cloudshaper::VERSION
    end

    private

    def load_stack(stack, _options, pull = true)
      Cloudshaper::Stacks.load
      pull(stack) if remote_state? && pull
      stack = Cloudshaper::Stacks.stacks[stack]
      stack.get
      stack
    end

    def remote_state?
      ret = options['remote_state'] == true
    end
  end
end
