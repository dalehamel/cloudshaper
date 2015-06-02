class SimpleApp < StackTemplate

  variable(:flavor) { default 'm1.small' }
  variable(:ami) { default 'ami-50948838' }
  variable(:region) { default 'us-east-1' }
  variable(:availability_zone) { default 'us-east-1b' }
  variable(:cidr) { default '10.1.2.0/24' }
  variable(:name) { default 'default' }
  variable(:key) {}

  provider "aws" do
    region var(:region)
  end

  resource "aws_security_group", :basic_web do
    name "simple_app_web"
    description "Basic security group with port 22, 80, 443 open to the world."

    ingress {
      from_port 22
      to_port 22
      protocol "tcp"
      cidr_blocks ["0.0.0.0/0"]
    }

    ingress {
      from_port 80
      to_port 80
      protocol "tcp"
      cidr_blocks ["0.0.0.0/0"]
    }

    ingress {
      from_port 443
      to_port 443
      protocol "tcp"
      cidr_blocks ["0.0.0.0/0"]
    }

  end

  resource "aws_vpc", :simple_vpc do
    cidr_block var(:cidr)
    tags ({
      'Name' => var(:name)
    })
  end

  resource "aws_subnet", :simple_subnet do
    vpc_id id_of("aws_vpc", :simple_vpc)
    cidr_block var(:cidr)
  end

  resource "aws_instance", :simple_app do
    security_groups [value_of("aws_security_group", :basic_web, :name)]
    instance_type var(:flavor)
    ami var(:ami)
    key_name var(:key)
    tags ({
      'Name' => "#{var(:name)}.ec2.shopify.com"
    })
  end

end
