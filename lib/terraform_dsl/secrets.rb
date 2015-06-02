require 'json'
require 'open3'

class SecretHash < Hash
  class SecretNotFound < StandardError; end

  def initialize
    super { |secrets, key| raise SecretNotFound.new("Secret `#{key}` not found") }
  end
end

unless ENV['TERRAFORM_ENV'] == 'test'
  Secrets ||= begin
    secrets_file = File.expand_path(ENV['CONFIG_PATH'] || '../config/secrets.json', __dir__) # FIXME - fix path here
    raise "config/secrets.json not found" unless File.exist?(secrets_file)
    JSON.parse(File.read(secrets_file), symbolize_names: true, object_class: SecretHash)
  end
else
  Secrets ||= {
    aws: {
      access_key_id: 'foo',
      secret_access_key: 'bar',
    }
  }
end
