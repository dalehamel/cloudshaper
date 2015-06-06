require 'json'
require 'open3'

# Load and provide access to secrets required by terraform providers
class SecretHash < Hash
  class SecretNotFound < Exception; end

  def initialize
    super { |_secrets, key| fail SecretNotFound, "Secret `#{key}` not found" }
  end
end

if ENV['TERRAFORM_ENV'] == 'test'
  SECRETS ||= {
    aws: {
      access_key_id: 'foo',
      secret_access_key: 'bar'
    }
  }
else
  SECRETS ||= begin
    secrets_file = File.expand_path(ENV['CONFIG_PATH'] || 'config/secrets.json')
    if File.exist?(secrets_file)
      JSON.parse(File.read(secrets_file), symbolize_names: true, object_class: SecretHash)
    else
      {}
    end
  end
end
