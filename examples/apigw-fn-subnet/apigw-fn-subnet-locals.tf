# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Dependencies:
#   - module-oci-networking.tf file
#   - module-defaults.tf file

locals {
  create_new_vcn = false
  create_subnets = (var.create_subnets) ? true : false
  subnets        = concat(local.subnets_apigw_fn)
  route_tables   = concat(local.route_tables_apigw_fn)
  security_lists = concat(local.security_lists_apigw_fn)
}

# OKE Subnets definitions
locals {
  subnets_apigw_fn = [
    {
      subnet_name                = "api_gw_fn_subnet"
      cidr_block                 = lookup(local.network_cidrs, "APIGW-FN-REGIONAL-SUBNET-CIDR")
      display_name               = "API Gateway and Fn subnet (${local.deploy_id})"
      dns_label                  = "apigwfn${local.deploy_id}"
      prohibit_public_ip_on_vnic = false
      prohibit_internet_ingress  = false
      route_table_id             = module.route_tables["apigw_fn_public"].route_table_id # TODO: implement data.oci_core_route_tables to get existent
      dhcp_options_id            = module.vcn.default_dhcp_options_id
      security_list_ids          = [module.security_lists["apigw_fn_security_list"].security_list_id]
      ipv6cidr_block             = null
    }
  ]
}

# OKE Route Tables definitions
locals {
  route_tables_apigw_fn = [{
    route_table_name = "apigw_fn_public"
    display_name     = "API Gateway and Fn Gatw Route Table (${local.deploy_id})"
    route_rules = [
      {
        description       = "Traffic to/from internet"
        destination       = lookup(local.network_cidrs, "ALL-CIDR")
        destination_type  = "CIDR_BLOCK"
        network_entity_id = module.gateways.internet_gateway_id
    }]
  }]
}

# OKE Security Lists definitions
locals {
  security_lists_apigw_fn = [
    {
      security_list_name = "apigw_fn_security_list"
      display_name       = "API Gateway and Fn Security List (${local.deploy_id})"
      egress_security_rules = [
        {
          description      = "Allow API Gateway to forward requests to Functions via service conduit"
          destination      = lookup(data.oci_core_services.all_services.services[0], "cidr_block")
          destination_type = "SERVICE_CIDR_BLOCK"
          protocol         = local.security_list_ports.all_protocols
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
      }]
      ingress_security_rules = [
        {
          description  = "Allow API Gateway to receive requests"
          source       = lookup(var.network_cidrs, "ALL-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.https_port_number, min = local.security_list_ports.https_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
      }]
    }
  ]
  security_list_ports = {
    http_port_number                        = 80
    https_port_number                       = 443
    k8s_api_endpoint_port_number            = 6443
    k8s_worker_to_control_plane_port_number = 12250
    ssh_port_number                         = 22
    tcp_protocol_number                     = "6"
    icmp_protocol_number                    = "1"
    all_protocols                           = "all"
  }
}

# Network locals
locals {
  network_cidrs = {
    APIGW-FN-REGIONAL-SUBNET-CIDR = cidrsubnet(local.vcn_cidr_blocks[0], 8, 30) # e.g.: "10.20.30.0/24" = 254 usable IPs (10.20.30.0 - 10.20.30.255)
    ALL-CIDR                      = "0.0.0.0/0"
  }
}

# Available OCI Services
data "oci_core_services" "all_services_network" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}
