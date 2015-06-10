module Cloudshaper
  # Aws provider-specific functionality, to be mixed in to stack elements
  module Aws
    def self.taggable?(resource_type)
      supports_tagging = [:aws_autoscaling_group, :aws_customer_gateway,
                          :aws_db_instance, :aws_elasticache_cluster,
                          :aws_elb, :aws_instance, :aws_internet_gateway,
                          :aws_network_acl, :aws_network_interface, :aws_route53_zone,
                          :aws_route_table, :aws_s3_bucket, :aws_security_group,
                          :aws_subnet, :aws_vpc, :aws_vpc_dhcp_options,
                          :aws_vpc_peering_connection, :aws_vpn_connection,
                          :aws_vpn_gateway]
      supports_tagging.include?(resource_type.to_sym)
    end

    # Tag all resources (that support tagging) that we created with this stack id
    def post_processing_aws
      return unless Aws.taggable?(@resource_type)
      @fields[:tags] ||= {}
      @fields[:tags][:cloudshaper_stack_id] = var(:cloudshaper_stack_id)
    end
  end
end
