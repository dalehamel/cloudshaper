require 'test_helper'

class StackModuleTest < Minitest::Test
  include Cloudshaper

  def test_multiple_instantiations_of_module
    StackModule.define 'factory_instantiation_test' do
      variable(:ports) { default '22' }
      resource 'aws_security_group', :a do
        get(:ports).split(',').each do |port|
          ingress { from_port port }
        end
      end
    end

    first  = StackModules.get('factory_instantiation_test')
    second = StackModules.get('factory_instantiation_test')

    first.build(ports: '80')
    second.build(ports: '443')

    sg_first = first.elements[:resource][:aws_security_group][:a]
    sg_second = second.elements[:resource][:aws_security_group][:a]

    assert_equal '80', sg_first[:ingress].fetch(:from_port)
    assert_equal '443', sg_second[:ingress].fetch(:from_port)
  end

  #   it 'should register variables with default values' do
  #     mod = StackModule.define('variable_register_default') { variable(:name) { default 'default' } }
  #     mod.build

  #     expect(mod.variables).to be_a(Hash)
  #     expect(mod.variables).to include(:name)
  #     expect(mod.variables[:name]).to be_a(Hash)
  #     expect(mod.variables[:name]).to include(:default)
  #     expect(mod.variables[:name][:default]).to eq('default')
  #   end

  #   it 'should register variables without default values' do
  #     mod = StackModule.define('variable_register_nodefault') { variable(:name) {} }
  #     mod.build

  #     expect(mod.variables).to be_a(Hash)
  #     expect(mod.variables).to include(:name)
  #     expect(mod.variables[:name]).to be_a(Hash)
  #     expect(mod.variables[:name]).to include(:default)
  #     expect(mod.variables[:name][:default]).to eq('')
  #   end

  #   it 'should accept variables at runtime' do
  #     mod = StackModule.define('variable_override') { variable(:name) { default 'default' } }
  #     mod.build(name: 'not-default')

  #     expect(mod.variables[:name][:default]).to eql('not-default')
  #   end
  # end

  def test_register_resource
    mod = StackModule.define('register_resource') { resource('aws_instance', :a) { default 'default' } }
    mod.build

    instance = mod.elements.fetch(:resource).fetch(:aws_instance).fetch(:a)
    assert_equal 'default', instance.fetch(:default)
  end

  def test_register_resource_with_connections
    mod = StackModule.define 'register_connection_test' do
      resource 'aws_instance', :a do
        connection do
          user 'root'
        end
      end
    end
    mod.build

    instance = mod.elements.fetch(:resource).fetch(:aws_instance).fetch(:a)
    assert_equal 'root', instance.fetch(:connection).fetch(:user)
  end

  def test_register_resource_with_provisioners_with_connections
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

    instance    = mod.elements.fetch(:resource).fetch(:aws_instance).fetch(:a)
    provisioner = instance.fetch(:provisioner).first
    connection  = provisioner.fetch(:file).fetch(:connection)
    assert_equal 'root', connection.fetch(:user)
  end

  def test_group_attributes_into_arrays
    mod = StackModule.define 'resource_scalar_variable_groups' do
      resource 'aws_security_group', :a do
        ingress { from_port 80 }
        ingress { from_port 443 }
      end
    end
    mod.build

    sg = mod.elements.fetch(:resource).fetch(:aws_security_group).fetch(:a)
    ingress = sg.fetch(:ingress)

    assert_kind_of Array, ingress
    assert_equal [{from_port: 80}, {from_port: 443}], ingress
  end

  def test_support_overriding_attributes
    mod = StackModule.define 'resource_overriden_runtime_variable' do
      variable(:ports) { default '22' }
      resource 'aws_security_group', :a do
        get(:ports).split(',').each do |port|
          ingress { from_port port }
        end
      end
    end
    mod.build(ports: '22,80,443')


    sg = mod.elements.fetch(:resource).fetch(:aws_security_group).fetch(:a)
    ingress = sg.fetch(:ingress)
    assert_equal [{from_port: "22"}, {from_port: "80"}, {from_port: "443"}], ingress
  end


  #   it 'it should be able to access overridden default variables at runtime' do
  #     mod = StackModule.define 'resource_overriden_runtime_variable' do
  #       variable(:ports) { default '22' }
  #       resource 'aws_security_group', :a do
  #         get(:ports).split(',').each do |port|
  #           ingress { from_port port }
  #         end
  #       end
  #     end

  #     mod.build(ports: '22,80,443')

  #     sg = mod.elements[:resource][:aws_security_group][:a]
  #     expect(sg).to include(:ingress)
  #     expect(sg[:ingress]).to be_a(Array)
  #     expect(sg[:ingress].first).to eq(from_port: '22')
  #     expect(sg[:ingress].last).to eq(from_port: '443')
  #   end
  # end
end
