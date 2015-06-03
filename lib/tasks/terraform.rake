require_relative '../terraform_dsl.rb'
require 'securerandom'

desc 'Loads available stack templates'
task :load do
  Terraform::Stacks.load
end

desc 'List all available stacks'
task list: :load do
  Terraform::Stacks.stacks.each do |name, _stack|
    puts name
  end
end

desc 'Apply all pending stack changes'
task apply_all: :load do
  Terraform::Stacks.stacks.each do |_name, stack|
    puts stack
    stack.apply
  end
end

desc 'Show all pending stack changes'
task show_all: :load do
  Terraform::Stacks.stacks.each do |_name, stack|
    puts stack
    stack.plan
  end
end

desc 'Show details about a stack by name'
task :show, [:name] => :load do |_t, args|
  fail 'Specify a name' unless args[:name]
  stack = Terraform::Stacks.stacks[args[:name]]
  puts stack
  stack.show
end

desc 'Show pending changes for a stack'
task :plan, [:name] => :load do |_t, args|
  fail 'Specify a name' unless args[:name]
  stack = Terraform::Stacks.stacks[args[:name]]
  stack.plan
end

desc 'Apply pending changes for a stack'
task :apply, [:name] => :load do |_t, args|
  fail 'Specify a name' unless args[:name]
  stack = Terraform::Stacks.stacks[args[:name]]
  stack.apply
end

desc 'Destroy a stack'
task :destroy, [:name] => :load do |_t, args|
  fail 'Specify a name' unless args[:name]
  stack = Terraform::Stacks.stacks[args[:name]]
  stack.destroy
end

desc 'Push stack states to remote location'
task push: :load do
  Terraform::Stacks.stacks.each do |_name, stack|
    puts stack
    stack.push
  end
end

desc 'Pulls stack states from remote location'
task pull: [:load, :remote_config] do
  Terraform::Stacks.stacks.each do |_name, stack|
    puts stack
    stack.pull
  end
end

desc 'Sets up remote config for all stacks that support it'
task remote_config: :load do
  Terraform::Stacks.stacks.each do |_name, stack|
    puts stack
    stack.remote_config
  end
end

desc 'Generate a UUID for a stack, so stacks do not clobber each other'
task :uuid do
  uuid = "#{Time.now.utc.to_i}_#{SecureRandom.urlsafe_base64(6)}"
  puts "uuid: #{uuid}"
  puts 'Add this as a field to a new stack to prevent clobbering stacks with the same name'
end
