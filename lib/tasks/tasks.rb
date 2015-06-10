require 'rake'

module Cloudshaper
  # Loads all rake tasks when terraform_dsl is included by a rake script
  class Tasks
    def self.loadall
      Dir.glob("#{File.join(File.dirname(__dir__), 'tasks')}/*.rake").each { |r| load r }
      template_path = ENV['TERRAFORM_TEMPLATE_PATH'] || 'templates'
      Dir.glob("#{File.join(Dir.pwd, template_path)}/*.rb").each { |t| require_relative t }
    end
  end
end
