# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_core_security_list" "extra_subnet_security_list" {
  compartment_id = var.oke_vcn_compartment_ocid
  display_name   = "${local.subnet_name_normalized}-seclist-${local.deploy_id}"
  vcn_id         = var.oke_vcn_ocid
  freeform_tags  = var.freeform_deployment_tags

  # Ingresses

  ingress_security_rules {
    description = "Allow API Gateway to receive requests"
    source      = lookup(var.network_cidrs, "ALL-CIDR")
    source_type = "CIDR_BLOCK"
    protocol    = local.tcp_protocol_number
    stateless   = false

    tcp_options {
      max = local.https_port_number
      min = local.https_port_number
    }
  }

  # Egresses

  egress_security_rules {
    description      = "Allow API Gateway to forward requests to Functions via service conduit"
    destination      = lookup(data.oci_core_services.all_services.services[0], "cidr_block")
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = local.all_protocols
    stateless        = false
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

locals {
  http_port_number                        = "80"
  https_port_number                       = "443"
  k8s_api_endpoint_port_number            = "6443"
  k8s_worker_to_control_plane_port_number = "12250"
  ssh_port_number                         = "22"
  tcp_protocol_number                     = "6"
  icmp_protocol_number                    = "1"
  all_protocols                           = "all"
}