require 'spec_helper'

RSpec.describe Terraform::StackModule do
  context 'variables' do
    it 'should register variables with default values' do
      mod = StackModule.define('variable_register_default') { variable(:name) { default 'default' } }
      mod.build

      expect(mod.variables).to be_a(Hash)
      expect(mod.variables).to include(:name)
      expect(mod.variables[:name]).to be_a(Hash)
      expect(mod.variables[:name]).to include(:default)
      expect(mod.variables[:name][:default]).to eq('default')
    end

    it 'should register variables without default values' do
      mod = StackModule.define('variable_register_nodefault') { variable(:name) { } }
      mod.build

      expect(mod.variables).to be_a(Hash)
      expect(mod.variables).to include(:name)
      expect(mod.variables[:name]).to be_a(Hash)
      expect(mod.variables[:name]).to include(:default)
      expect(mod.variables[:name][:default]).to eq('')
    end

    it 'should accept variables at runtime' do
      mod = StackModule.define('variable_override') { variable(:name) { default 'default' } }
      mod.build(name: 'not-default')

      expect(mod.variables[:name][:default]).to eql('not-default')
    end

  end

  context 'resources' do
    it 'should register resources' do
      mod = StackModule.define('register_resource') { resource('aws_instance', :a) { default 'default' } }
      mod.build

      instance = mod.elements[:resource][:aws_instance]
      expect(instance).to include(:a)
      expect(instance[:a]).to be_a(Hash)
      expect(instance[:a]).to include(:default)
      expect(instance[:a][:default]).to eql('default')
    end

    it 'should register resources with connections' do
      mod = StackModule.define 'register_connection_test' do
        resource 'aws_instance', :a do
          connection do
            user 'root'
          end
        end
      end
      mod.build

      instance = mod.elements[:resource][:aws_instance][:a]
      expect(instance).to include(:connection)
      expect(instance[:connection]).to be_a(Hash)
      expect(instance[:connection]).to eq(user: 'root')
    end

    it 'should register resources with provisioners with connections' do

      mod = StackModule.define 'register_provision_connection_test' do
        resource 'aws_instance', :a do
          provisioner 'file' do
            connection do
              user 'root'
            end
          end
        end
      end
      mod.build

      instance = mod.elements[:resource][:aws_instance][:a]
      expect(instance).to include(:provisioner)
      expect(instance[:provisioner].first).to include(:file)
      expect(instance[:provisioner].first[:file][:connection]).to eq(user: 'root')
    end

    it 'should group resource attributes from scalars to arrays when defined more than once' do
      mod = StackModule.define 'resource_scalar_variable_groups' do
        resource 'aws_security_group', :a do
          ingress { from_port 80 }
          ingress { from_port 443 }
        end

      end
      mod.build


      sg = mod.elements[:resource][:aws_security_group][:a]
      expect(sg).to include(:ingress)
      expect(sg[:ingress]).to be_a(Array)
      expect(sg[:ingress].first).to eq(from_port: 80)
      expect(sg[:ingress].last).to eq(from_port: 443)
    end


    it 'it should be able to access overridden default variables at runtime' do
      mod = StackModule.define 'resource_overriden_runtime_variable' do
        variable(:ports){ default '22' }
        resource 'aws_security_group', :a do
          get(:ports).split(',').each do |port|
            ingress { from_port port }
          end
        end
      end

      mod.build(ports: '22,80,443')

      sg = mod.elements[:resource][:aws_security_group][:a]
      expect(sg).to include(:ingress)
      expect(sg[:ingress]).to be_a(Array)
      expect(sg[:ingress].first).to eq(from_port: '22')
      expect(sg[:ingress].last).to eq(from_port: '443')
    end

  end
end
