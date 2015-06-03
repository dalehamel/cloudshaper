require_relative 'aws/remote_s3.rb'

module Terraform
  class Remote < Command
    class RemoteNotSupported < Exception; end
    include Aws::Remote_S3
    def initialize(stack, command)
      super

      backend = @stack.remote.keys.first
      sym = "options_for_#{backend}"

      if self.respond_to?(sym, include_private: true)
        @command = send(sym, command)
      else
        fail RemoteNotSupported, "Remote backend #{backend} is not supported yet"
      end
    end
  end
end
