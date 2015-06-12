require 'test_helper'

class StackModuleTest < Minitest::Test
  include Cloudshaper

  def setup
    StackModules.reset!
  end

  def test_multiple_modules_same_name_raises_exception
    StackModule.define 'same_name_test'
    assert_raises(StackModules::ModuleAlreadyRegistered) do
      StackModule.define 'same_name_test'
    end
  end

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

    sg_first = first.get_resource(:aws_security_group, :a)
    sg_second = second.get_resource(:aws_security_group, :a)

    assert_equal '80', sg_first[:ingress].fetch(:from_port)
    assert_equal '443', sg_second[:ingress].fetch(:from_port)
  end

  def test_module_build_registers_variable_with_defaults
    mod = StackModule.define('variable_register_default') do
      variable(:name) { default 'spam' }
    end
    mod.build

    assert_equal 'spam', mod.get(:name)
  end

  def test_module_build_registers_variables_without_defaults
    mod = StackModule.define('variable_register_nodefault') { variable(:name) {} }
    mod.build

    assert_equal '', mod.get(:name)
  end

  def test_module_build_registers_variables_at_runtime
    mod = StackModule.define('variable_override') do
      variable(:name) { default 'default' }
    end
    mod.build(name: 'not-default')

    assert_equal 'not-default', mod.get(:name)
  end

  def test_register_resource
    mod = StackModule.define('register_resource') do
      resource('aws_instance', :a) { default 'default' }
    end
    mod.build

    instance = mod.get_resource(:aws_instance, :a)
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

    instance = mod.get_resource(:aws_instance, :a)
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

    instance    = mod.get_resource(:aws_instance, :a)
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

    sg = mod.get_resource(:aws_security_group, :a)
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

    sg = mod.get_resource(:aws_security_group, :a)
    ingress = sg.fetch(:ingress)
    assert_equal [{from_port: "22"}, {from_port: "80"}, {from_port: "443"}], ingress
  end
end
