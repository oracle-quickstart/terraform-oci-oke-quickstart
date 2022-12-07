# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Network locals
locals {
  vcn_cidr_blocks = split(",", var.vcn_cidr_blocks)
  network_cidrs = {
    VCN-MAIN-CIDR                                  = local.vcn_cidr_blocks[0]                      # e.g.: "10.75.0.0/16" = 65536 usable IPs
    VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR = cidrsubnet(local.vcn_cidr_blocks[0], 1, 1)    # e.g.: "10.75.128.0/17" = 32766 usable IPs (10.20.128.0 - 10.20.255.255)
    SUBNET-5GC-OAM-CIDR                            = cidrsubnet(local.vcn_cidr_blocks[0], 9, 128)  # e.g.: "10.75.64.0/25" = 128 usable IPs
    SUBNET-5GC-SIGNALLING-CIDR                     = cidrsubnet(local.vcn_cidr_blocks[0], 9, 129)  # e.g.: "10.75.64.128/25" = 128 usable IPs
    SUBNET-5G-RAN-CIDR                             = cidrsubnet(local.vcn_cidr_blocks[0], 11, 520) # e.g.: "10.75.65.0/27" = 32 usable IPs
    SUBNET-LEGAL-INTERCEPT-CIDR                    = cidrsubnet(local.vcn_cidr_blocks[0], 11, 521) # e.g.: "10.75.65.32/27" = 32 usable IPs
    SUBNET-5G-EPC-CIDR                             = cidrsubnet(local.vcn_cidr_blocks[0], 11, 522) # e.g.: "10.75.65.64/27" = 32 usable IPs
    ALL-CIDR                                       = "0.0.0.0/0"
  }
}

# Extra Security Lists for the 5G NF
locals {
  extra_security_lists = [
    {
      security_list_name     = "5gc_oam_security_list"
      display_name           = "5GC OAM Security List"
      ingress_security_rules = concat(local.common_5g_security_list_ingress_rules, local.temp_all_vcn_security_list_ingress_rules)
      egress_security_rules  = concat(local.common_5g_security_list_egress_rules, local.temp_all_vcn_security_list_egress_rules)
    },
    {
      security_list_name     = "5gc_signalling_security_list"
      display_name           = "5GC Signalling (SBI) Security List"
      ingress_security_rules = concat(local.common_5g_security_list_ingress_rules, local.temp_all_vcn_security_list_ingress_rules)
      egress_security_rules  = concat(local.common_5g_security_list_egress_rules, local.temp_all_vcn_security_list_egress_rules)
    },
    {
      security_list_name     = "5g_ran_security_list"
      display_name           = "5G RAN Security List"
      ingress_security_rules = concat(local.common_5g_security_list_ingress_rules, local.temp_all_vcn_security_list_ingress_rules)
      egress_security_rules  = concat(local.common_5g_security_list_egress_rules, local.temp_all_vcn_security_list_egress_rules)
    },
    {
      security_list_name     = "legal_intercept_security_list"
      display_name           = "Legal Intercept Security List"
      ingress_security_rules = concat(local.common_5g_security_list_ingress_rules, local.temp_all_vcn_security_list_ingress_rules)
      egress_security_rules  = concat(local.common_5g_security_list_egress_rules, local.temp_all_vcn_security_list_egress_rules)
    },
    {
      security_list_name     = "5g_epc_security_list"
      display_name           = "5G EPC Security List"
      ingress_security_rules = concat(local.common_5g_security_list_ingress_rules, local.temp_all_vcn_security_list_ingress_rules)
      egress_security_rules  = concat(local.common_5g_security_list_egress_rules, local.temp_all_vcn_security_list_egress_rules)
      }, {
      security_list_name = "5g_for_pods_security_list"
      display_name       = "5G subnets x pods Security List"
      ingress_security_rules = [{
        description  = "Allow 5GC OAM to pod communication"
        source       = lookup(local.network_cidrs, "SUBNET-5GC-OAM-CIDR")
        source_type  = "CIDR_BLOCK"
        protocol     = local.security_list_ports.all_protocols
        stateless    = false
        tcp_options  = { max = -1, min = -1, source_port_range = null }
        udp_options  = { max = -1, min = -1, source_port_range = null }
        icmp_options = null
        }, {
        description  = "Allow 5GC Signalling (SBI) to pod communication"
        source       = lookup(local.network_cidrs, "SUBNET-5GC-SIGNALLING-CIDR")
        source_type  = "CIDR_BLOCK"
        protocol     = local.security_list_ports.all_protocols
        stateless    = false
        tcp_options  = { max = -1, min = -1, source_port_range = null }
        udp_options  = { max = -1, min = -1, source_port_range = null }
        icmp_options = null
        }, {
        description  = "Allow 5G RAN to pod communication"
        source       = lookup(local.network_cidrs, "SUBNET-5G-RAN-CIDR")
        source_type  = "CIDR_BLOCK"
        protocol     = local.security_list_ports.all_protocols
        stateless    = false
        tcp_options  = { max = -1, min = -1, source_port_range = null }
        udp_options  = { max = -1, min = -1, source_port_range = null }
        icmp_options = null
        }, {
        description  = "Allow 5G Legal Intercept to pod communication"
        source       = lookup(local.network_cidrs, "SUBNET-LEGAL-INTERCEPT-CIDR")
        source_type  = "CIDR_BLOCK"
        protocol     = local.security_list_ports.all_protocols
        stateless    = false
        tcp_options  = { max = -1, min = -1, source_port_range = null }
        udp_options  = { max = -1, min = -1, source_port_range = null }
        icmp_options = null
        }, {
        description  = "Allow 5G EPC to pod communication"
        source       = lookup(local.network_cidrs, "SUBNET-5G-EPC-CIDR")
        source_type  = "CIDR_BLOCK"
        protocol     = local.security_list_ports.all_protocols
        stateless    = false
        tcp_options  = { max = -1, min = -1, source_port_range = null }
        udp_options  = { max = -1, min = -1, source_port_range = null }
        icmp_options = null
      }]
      egress_security_rules = []
    },
  ]
  common_5g_security_list_ingress_rules = [{
    description  = "Allow pods to communicate with 5G subnets"
    source       = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
    source_type  = "CIDR_BLOCK"
    protocol     = local.security_list_ports.all_protocols
    stateless    = false
    tcp_options  = { max = -1, min = -1, source_port_range = null }
    udp_options  = { max = -1, min = -1, source_port_range = null }
    icmp_options = null
    }, {
    description  = "Path discovery"
    source       = lookup(local.network_cidrs, "ALL-CIDR")
    source_type  = "CIDR_BLOCK"
    protocol     = local.security_list_ports.icmp_protocol_number
    stateless    = false
    tcp_options  = { max = -1, min = -1, source_port_range = null }
    udp_options  = { max = -1, min = -1, source_port_range = null }
    icmp_options = { type = "3", code = "4" }
  }]
  common_5g_security_list_egress_rules = [{
    description      = "Allow 5G subnets to communicate with pods"
    destination      = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.security_list_ports.all_protocols
    stateless        = false
    tcp_options      = { max = -1, min = -1, source_port_range = null }
    udp_options      = { max = -1, min = -1, source_port_range = null }
    icmp_options     = null
    }, {
    description      = "Path discovery"
    destination      = lookup(local.network_cidrs, "ALL-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.security_list_ports.icmp_protocol_number
    stateless        = false
    tcp_options      = { max = -1, min = -1, source_port_range = null }
    udp_options      = { max = -1, min = -1, source_port_range = null }
    icmp_options     = { type = "3", code = "4" }
  }]
  temp_all_vcn_security_list_ingress_rules = [{
    description  = "Allow all from VCN"
    source       = lookup(local.network_cidrs, "VCN-MAIN-CIDR")
    source_type  = "CIDR_BLOCK"
    protocol     = local.security_list_ports.all_protocols
    stateless    = false
    tcp_options  = { max = -1, min = -1, source_port_range = null }
    udp_options  = { max = -1, min = -1, source_port_range = null }
    icmp_options = null
  }]
  temp_all_vcn_security_list_egress_rules = [{
    description      = "Allow all to VCN"
    destination      = lookup(local.network_cidrs, "VCN-MAIN-CIDR")
    destination_type = "CIDR_BLOCK"
    protocol         = local.security_list_ports.all_protocols
    stateless        = false
    tcp_options      = { max = -1, min = -1, source_port_range = null }
    udp_options      = { max = -1, min = -1, source_port_range = null }
    icmp_options     = null
  }]
  security_list_ports = {
    http_port_number                        = 80
    https_port_number                       = 443
    k8s_api_endpoint_port_number            = 6443
    k8s_api_endpoint_to_worker_port_number  = 10250
    k8s_worker_to_control_plane_port_number = 12250
    ssh_port_number                         = 22
    tcp_protocol_number                     = "6"
    udp_protocol_number                     = "17"
    icmp_protocol_number                    = "1"
    all_protocols                           = "all"
  }
}

# Extra Subnets for for the 5G NF
locals {
  extra_subnets = [
    {
      subnet_name                  = "5GC_OAM_subnet"
      cidr_block                   = lookup(local.network_cidrs, "SUBNET-5GC-OAM-CIDR")
      display_name                 = "5GC OAM subnet"
      dns_label                    = "sn5gcoam"
      prohibit_public_ip_on_vnic   = true
      prohibit_internet_ingress    = true
      route_table_id               = null
      alternative_route_table_name = "private"
      dhcp_options_id              = ""
      security_list_ids            = []
      extra_security_list_names    = ["5gc_oam_security_list"]
      ipv6cidr_block               = null
    },
    {
      subnet_name                  = "5GC_Signalling_subnet"
      cidr_block                   = lookup(local.network_cidrs, "SUBNET-5GC-SIGNALLING-CIDR")
      display_name                 = "5GC Signalling (SBI) subnet"
      dns_label                    = "sn5gcsig"
      prohibit_public_ip_on_vnic   = true
      prohibit_internet_ingress    = true
      route_table_id               = null
      alternative_route_table_name = "private"
      dhcp_options_id              = ""
      security_list_ids            = []
      extra_security_list_names    = ["5gc_signalling_security_list"]
      ipv6cidr_block               = null
    },
    {
      subnet_name                  = "5G_RAN_subnet"
      cidr_block                   = lookup(local.network_cidrs, "SUBNET-5G-RAN-CIDR")
      display_name                 = "5G RAN subnet"
      dns_label                    = "sn5gran"
      prohibit_public_ip_on_vnic   = true
      prohibit_internet_ingress    = true
      route_table_id               = null
      alternative_route_table_name = "private"
      dhcp_options_id              = ""
      security_list_ids            = []
      extra_security_list_names    = ["5g_ran_security_list"]
      ipv6cidr_block               = null
    },
    {
      subnet_name                  = "Legal_Intercept_subnet"
      cidr_block                   = lookup(local.network_cidrs, "SUBNET-LEGAL-INTERCEPT-CIDR")
      display_name                 = "Legal Intercept subnet"
      dns_label                    = "snlegalin"
      prohibit_public_ip_on_vnic   = true
      prohibit_internet_ingress    = true
      route_table_id               = null
      alternative_route_table_name = "private"
      dhcp_options_id              = ""
      security_list_ids            = []
      extra_security_list_names    = ["legal_intercept_security_list"]
      ipv6cidr_block               = null
    },
    {
      subnet_name                  = "5G_EPC_subnet"
      cidr_block                   = lookup(local.network_cidrs, "SUBNET-5G-EPC-CIDR")
      display_name                 = "5G EPC subnet"
      dns_label                    = "sn5gcepc"
      prohibit_public_ip_on_vnic   = true
      prohibit_internet_ingress    = true
      route_table_id               = null
      alternative_route_table_name = "private"
      dhcp_options_id              = ""
      security_list_ids            = []
      extra_security_list_names    = ["5g_epc_security_list"]
      ipv6cidr_block               = null
    },
  ]
}

# Node Pool 1 info for 5G VNICs attachments
data "oci_containerengine_node_pool" "node_pool_1" {
  node_pool_id = module.oke-quickstart.oke_node_pools["pool1"].node_pool_id # local.node_pool_1_id # module.oke-quickstart.oke_node_pools["pool1"].node_pool_id
}
# locals {
#   node_pool_nodes = data.oci_containerengine_node_pool.node_pool_1.nodes
#   node_pool_1_id  = module.oke-quickstart.oke_node_pools["pool1"].node_pool_id
# }
# module "_vnic_attachments" {
#   source          = "./modules/_vnic-attachments"
#   network_cidrs   = local.network_cidrs
#   node_pool_nodes = data.oci_containerengine_node_pool.node_pool_1.nodes # local.node_pool_nodes
#   subnets         = module.oke-quickstart.subnets

#   depends_on = [
#     module.oke-quickstart
#   ]
# }
# module "_vnic_attachment2" {
#   # for_each = { for map in data.oci_containerengine_node_pool.node_pool_1.nodes : map.id => map }
#   count = 5
#   source          = "./modules/_vnic-attachment2"
#   network_cidrs   = local.network_cidrs
#   node_pool_node_id = data.oci_containerengine_node_pool.node_pool_1.nodes[count.index].id
#   node_pool_nodes = data.oci_containerengine_node_pool.node_pool_1.nodes
#   subnets         = module.oke-quickstart.subnets

#   depends_on = [
#     module.oke-quickstart
#   ]
# }


# 5G NF VNICs attachments for each node in the node pool
resource "oci_core_vnic_attachment" "vnic_attachment_5gc_oam" {
  count = var.node_pool_initial_num_worker_nodes_1
  create_vnic_details {
    display_name  = "5GC-OAM vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(local.network_cidrs, "SUBNET-5GC-OAM-CIDR"), hostnum)][index(data.oci_containerengine_node_pool.node_pool_1.nodes.*.id, data.oci_containerengine_node_pool.node_pool_1.nodes[count.index].id)]
    subnet_id     = module.oke-quickstart.subnets["5GC_OAM_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5GC-OAM" }
  }
  instance_id = data.oci_containerengine_node_pool.node_pool_1.nodes[count.index].id
}
resource "oci_core_vnic_attachment" "vnic_attachment_5gc_signalling" {
  count = var.node_pool_initial_num_worker_nodes_1
  create_vnic_details {
    display_name  = "5GC-Signalling vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(local.network_cidrs, "SUBNET-5GC-SIGNALLING-CIDR"), hostnum)][index(data.oci_containerengine_node_pool.node_pool_1.nodes.*.id, data.oci_containerengine_node_pool.node_pool_1.nodes[count.index].id)]
    subnet_id     = module.oke-quickstart.subnets["5GC_Signalling_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5GC-Signalling" }
  }
  instance_id = data.oci_containerengine_node_pool.node_pool_1.nodes[count.index].id
}
resource "oci_core_vnic_attachment" "vnic_attachment_5g_ran" {
  count = var.node_pool_initial_num_worker_nodes_1
  create_vnic_details {
    display_name  = "5G RAN vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(local.network_cidrs, "SUBNET-5G-RAN-CIDR"), hostnum)][index(data.oci_containerengine_node_pool.node_pool_1.nodes.*.id, data.oci_containerengine_node_pool.node_pool_1.nodes[count.index].id)]
    subnet_id     = module.oke-quickstart.subnets["5G_RAN_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5G RAN" }
  }
  instance_id = data.oci_containerengine_node_pool.node_pool_1.nodes[count.index].id
}
resource "oci_core_vnic_attachment" "vnic_attachment_5g_legal_intercept" {
  count = var.node_pool_initial_num_worker_nodes_1
  create_vnic_details {
    display_name  = "5G Legal Intercept vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(local.network_cidrs, "SUBNET-LEGAL-INTERCEPT-CIDR"), hostnum)][index(data.oci_containerengine_node_pool.node_pool_1.nodes.*.id, data.oci_containerengine_node_pool.node_pool_1.nodes[count.index].id)]
    subnet_id     = module.oke-quickstart.subnets["Legal_Intercept_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5G Legal Intercept" }
  }
  instance_id = data.oci_containerengine_node_pool.node_pool_1.nodes[count.index].id
}
resource "oci_core_vnic_attachment" "vnic_attachment_5g_epc" {
  count = var.node_pool_initial_num_worker_nodes_1
  create_vnic_details {
    display_name  = "5G-EPC vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(local.network_cidrs, "SUBNET-5G-EPC-CIDR"), hostnum)][index(data.oci_containerengine_node_pool.node_pool_1.nodes.*.id, data.oci_containerengine_node_pool.node_pool_1.nodes[count.index].id)]
    subnet_id     = module.oke-quickstart.subnets["5G_EPC_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5G-EPC" }
  }
  instance_id = data.oci_containerengine_node_pool.node_pool_1.nodes[count.index].id
}
