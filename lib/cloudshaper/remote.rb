require 'cloudshaper/aws/remote_s3'

module Cloudshaper
  # Wrap 'remote' commands, such as config, pull, and push
  # This allows us to store state remotely using different providers
  class Remote < Command
    class RemoteNotSupported < Exception; end
    include Aws::RemoteS3
    def initialize(stack, command)
      super
      unless @stack.remote.first
        puts "\tWARNING: #{@stack.name} is not configured with a remote backend"
        return
      end

      backend = @stack.remote.keys.first
      sym = "options_for_#{backend}"

      if self.respond_to?(sym, include_private: true)
        @command = send(sym, command)
      else
        fail RemoteNotSupported, "Remote backend #{backend} is not supported yet"
      end
    end

    def execute
      return unless @stack.remote.first
      super
    end
  end
end
