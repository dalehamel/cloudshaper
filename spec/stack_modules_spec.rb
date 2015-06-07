require 'spec_helper'

RSpec.describe Terraform::StackModules do
  it 'it should provide separate instantiations of the same module' do
    StackModule.define 'factory_instantiation_test' do
      variable(:ports) { default '22' }
      resource 'aws_security_group', :a do
        get(:ports).split(',').each do |port|
          ingress { from_port port }
        end
      end
    end

    first = StackModules.get('factory_instantiation_test')
    second = StackModules.get('factory_instantiation_test')

    first.build(ports: '80')
    second.build(ports: '443')

    sg_first = first.elements[:resource][:aws_security_group][:a]
    sg_second = second.elements[:resource][:aws_security_group][:a]

    expect(sg_first[:ingress]).to eq(from_port: '80')
    expect(sg_second[:ingress]).to eq(from_port: '443')
  end
end
