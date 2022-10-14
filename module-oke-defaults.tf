# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# File Version: 0.7.1

# Dependencies:
#   - module-oci-networking.tf file
#   - module-defaults.tf file

################################################################################
# If you have extra configurations to add, you can add them here.
# It's supported to include:
#   - Extra Node Pools and their configurations
#   - Extra subnets
#   - Extra route tables and security lists
################################################################################

################################################################################
# Required locals for the oci-networking and oke modules
################################################################################
locals {
  node_pools                    = concat(local.node_pool_1, local.extra_node_pools)
  create_new_vcn                = (var.create_new_oke_cluster && var.create_new_vcn) ? true : false
  vcn_display_name              = "[${local.app_name}] VCN for OKE (${local.deploy_id})"
  create_subnets                = (var.create_new_oke_cluster || var.create_subnets) ? true : false
  subnets                       = concat(local.subnets_oke, local.extra_subnets)
  route_tables                  = concat(local.route_tables_oke)
  security_lists                = concat(local.security_lists_oke)
  resolved_vcn_compartment_ocid = (var.create_new_compartment_for_oke ? local.oke_compartment_ocid : var.compartment_ocid)
}

################################################################################
# Extra OKE node pools
# Example commented out below
################################################################################
locals {
  extra_node_pools = [
    # {
    #   node_pool_name                            = "GPU" # Must be unique
    #   node_pool_min_nodes                       = var.cluster_autoscaler_enabled ? 1 : 1
    #   node_pool_max_nodes                       = 2
    #   node_k8s_version                          = var.k8s_version
    #   node_pool_shape                           = "BM.GPU.A10.4"
    #   node_pool_shape_specific_ad                = 3 # Optional, if not provided or set = 0, will be randomly assigned
    #   node_pool_node_shape_config_ocpus         = 1
    #   node_pool_node_shape_config_memory_in_gbs = 1
    #   node_pool_boot_volume_size_in_gbs         = "100"
    #   existent_oke_nodepool_id_for_autoscaler   = null
    #   image_operating_system                    = null
    #   image_operating_system_version            = null
    #   extra_initial_node_labels                 = [{ key = "app.pixel/gpu", value = "true" }]
    #   cni_type                                  = "FLANNEL_OVERLAY" # "FLANNEL_OVERLAY" or "OCI_VCN_IP_NATIVE"
    # },
  ]
}

locals {
  extra_subnets = [
    # {
    #   subnet_name                = "opensearch_subnet"
    #   cidr_block                 = cidrsubnet(local.vcn_cidr_blocks[0], 8, 35) # e.g.: "10.20.35.0/24" = 254 usable IPs (10.20.35.0 - 10.20.35.255)
    #   display_name               = "OCI OpenSearch Service subnet (${local.deploy_id})"
    #   dns_label                  = "opensearch${local.deploy_id}"
    #   prohibit_public_ip_on_vnic = false
    #   prohibit_internet_ingress  = false
    #   route_table_id             = module.route_tables["public"].route_table_id
    #   dhcp_options_id            = module.vcn.default_dhcp_options_id
    #   security_list_ids          = [module.security_lists["opensearch_security_list"].security_list_id]
    #   ipv6cidr_block             = null
    # },
  ]
}