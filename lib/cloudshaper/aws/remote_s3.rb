module Cloudshaper
  module Aws
    # Support AWS S3 remote state backend
    module RemoteS3
      private

      def options_for_s3(command)
        options = ''
        options = "-backend=s3 #{config_opts_s3}" if command == :config
        "terraform remote #{command} #{options}"
      end

      def config_opts_s3
        config = "-backend-config='key=#{@stack.stack_id}' "
        config += @stack.remote['s3'].map { |k, v| "-backend-config='#{k}=#{v}'" }.join(' ')
        config
      end
    end
  end
end
