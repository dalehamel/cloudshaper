require 'spec_helper'

RSpec.describe Terraform::StackTemplate do
  context 'variables' do
    it 'should accept variable definitions' do
      class VarDefAccept < StackTemplate; end
      template = VarDefAccept
      template.variable(:name) { default 'default' }

      expect(template.variable_definitions[:name]).to be_a(StackTemplate::VariableDefinition)
      expect(template.variable_definitions[:name].name).to eql :name
      expect(template.variable_definitions[:name].default).to eql 'default'
    end

    it 'should populate variables hash from defaults' do
      class VarPopulate < StackTemplate; end
      template = VarPopulate
      template.variable(:name) { default 'default' }

      expect(template.variables).to be_a(Hash)
      expect(template.variables).to include(:name)
      expect(template.variables[:name]).to eql('default')
    end

    it 'should register variables' do
      class VarRegister < StackTemplate; end
      template = VarRegister
      template.variable(:a) { default 'default' }

      expect(template.stack_elements[:variable][:a]).to be_a(Hash)
      expect(template.stack_elements[:variable][:a]).to eql(default: 'default')
    end
  end

  context 'resources' do
    it 'should register resources' do
      class ResourceRegister < StackTemplate; end
      template = ResourceRegister
      template.resource('aws_instance', :a) { default 'default' }

      instance = template.stack_elements[:resource][:aws_instance]
      expect(instance).to include(:a)
      expect(instance[:a]).to be_a(Hash)
      expect(instance[:a]).to include(:default)
      expect(instance[:a][:default]).to eql('default')
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
