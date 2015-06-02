class SimpleApp < StackTemplate
  variable(:flavor) { default 'm1.small' }

  resource 'aws_instance', :simple_app do
    instance_type var(:flavor)
  end
end
