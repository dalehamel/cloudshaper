require 'spec_helper'

RSpec.describe Terraform::StackTemplate do

  context 'variables' do
    it 'should accept variable definitions' do
      template = Class.new(StackTemplate)
      template.variable(:name) { default 'default' }

      expect(template.variable_definitions[:name]).to be_a(StackTemplate::VariableDefinition)
      expect(template.variable_definitions[:name].name).to eql :name
      expect(template.variable_definitions[:name].default).to eql 'default'
    end

#    it 'should populate variables hash from defaults' do
#      template = Class.new(StackTemplate)
#      template.variable(:name) { default 'default' }
#
#      stack = Fabricate(:stack)
#      allow(stack).to receive(:template_class) { template }
#
#      expect(stack.template.variables).to eql(name: 'default')
#    end

#    it 'should populate variables hash from stack variables' do
#      template = Class.new(StackTemplate)
#      template.variable(:name) { default 'default' }
#
#      stack = Fabricate(:stack)
#      allow(stack).to receive(:template_class) { template }
#      stack.stack_variables.create!(key: 'name', value: 'explicit')
#
#      expect(stack.template.variables).to eql(name: 'explicit')
#    end
#
#    it 'should merge the variables hash from both sources' do
#      template = Class.new(StackTemplate)
#      template.variable(:a) { default 'default' }
#      template.variable(:b) { default 'default' }
#      template.variable(:c) { }
#      template.variable(:d) { }
#
#      stack = Fabricate(:stack)
#      allow(stack).to receive(:template_class) { template }
#      stack.stack_variables.create!(key: 'a', value: 'explicit')
#      stack.stack_variables.create!(key: 'c', value: 'explicit')
#
#      expect(stack.template.variables).to eql(a: 'explicit', b: 'default', c: 'explicit', d: nil)
#      expect(stack.variables).to eql(stack.template.variables)
#    end

    it 'should register variables' do
      template = Class.new(StackTemplate)
      template.variable(:a) { default 'default' }

      expect(template.stack_elements[:variable][:a]).to be_a(Hash)
      expect(template.stack_elements[:variable][:a]).to eql(default: 'default')
    end
  end

  context 'resources' do

    it 'should register resources' do
      template = Class.new(StackTemplate)
      template.resource('aws_instance', :a) { default 'default' }

      instance = template.stack_elements[:resource][:aws_instance]
      expect(instance).to include(:a)
      expect(instance[:a]).to be_a(Hash)
      expect(instance[:a]).to eql(default: 'default')
    end

     it 'should register resources with connections' do
      class ConnectionTest < StackTemplate
        resource 'aws_instance', :a do
          connection do
            user 'root'
          end
        end
      end

      instance = ConnectionTest.stack_elements[:resource][:aws_instance][:a]
      expect(instance).to include(:connection)
      expect(instance[:connection]).to be_a(Hash)
      expect(instance[:connection]).to eq(user: 'root')
    end

    it 'should register resources with provisioners with connections' do
      class ProvisionTest < StackTemplate
        resource 'aws_instance', :a do
          provisioner 'file' do
            connection do
              user 'root'
            end
          end
        end
      end

      instance = ProvisionTest.stack_elements[:resource][:aws_instance][:a]
      expect(instance).to include(:provisioner)
      expect(instance[:provisioner].first).to include(:file)
      expect(instance[:provisioner].first[:file][:connection]).to eq(user: 'root')

    end

     it 'should group resource attributes from scalars to arrays when defined more than once' do
      class ScalarTest < StackTemplate
        resource 'aws_security_group', :a do
          ingress { from_port 80 }
          ingress { from_port 443 }
        end
      end

      sg = ScalarTest.stack_elements[:resource][:aws_security_group][:a]
      expect(sg).to include(:ingress)
      expect(sg[:ingress]).to be_a(Array)
      expect(sg[:ingress].first).to eq(from_port: 80)
      expect(sg[:ingress].last).to eq(from_port: 443)
    end

 end
end
