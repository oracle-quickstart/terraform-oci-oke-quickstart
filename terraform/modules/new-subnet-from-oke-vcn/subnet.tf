# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_core_subnet" "extra_subnet" {
  cidr_block                 = lookup(var.network_cidrs, "EXTRA-SUBNET-REGIONAL-CIDR")
  compartment_id             = var.oke_vcn_compartment_ocid
  display_name               = "${local.subnet_name_normalized}-subnet-${random_string.deploy_id.result}"
  dns_label                  = "${local.subnet_name_normalized}${random_string.deploy_id.result}"
  vcn_id                     = var.oke_vcn_ocid
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.extra_subnet_route_table[0].id
  dhcp_options_id            = var.oke_vcn_default_dhcp_id
  security_list_ids          = [oci_core_security_list.extra_subnet_security_list[0].id]
  freeform_tags              = local.freeform_deployment_tags
}

resource "oci_core_route_table" "extra_subnet_route_table" {
  compartment_id = var.oke_vcn_compartment_ocid
  vcn_id         = var.oke_vcn_ocid
  display_name   = "${local.subnet_name_normalized}-route-table-${random_string.deploy_id.result}"
  freeform_tags  = local.freeform_deployment_tags

  route_rules {
    description       = "Traffic to/from internet"
    destination       = lookup(var.network_cidrs, "ALL-CIDR")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oke_internet_gateway[0].id
  }
}