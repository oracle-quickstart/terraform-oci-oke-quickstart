# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Gets supported Kubernetes versions for node pools
data "oci_containerengine_node_pool_option" "node_pool" {
  node_pool_option_id = "all"
}

# Gets a list of supported images based on the shape, operating_system and operating_system_version provided
data "oci_core_images" "node_pool_images" {
  compartment_id           = var.oke_cluster_compartment_ocid
  operating_system         = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape                    = var.node_pool_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}
# Gets a specfic Availability Domain
data "oci_identity_availability_domain" "specfic" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.node_pool_shape_specific_ad

  count = (var.node_pool_shape_specific_ad > 0) ? 1 : 0
}