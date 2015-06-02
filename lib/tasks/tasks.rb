require 'rake'

module Terraform
  # Loads all rake tasks when terraform_dsl is included by a rake script
  class Tasks
    def self.loadall
      Dir.glob("#{File.join(File.dirname(__dir__), 'tasks')}/*.rake").each { |r| load r }
    end
  end
end
