# Copyright (c) 2023 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

module "oke-quickstart" {
  source = "github.com/oracle-quickstart/terraform-oci-oke-quickstart?ref=0.9.0"

  providers = {
    oci             = oci
    oci.home_region = oci.home_region
  }

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  region           = var.region

  # Note: Just few arguments are showing here to simplify the basic example. All other arguments are using default values.
  # App Name to identify deployment. Used for naming resources.
  app_name = "Basic"

  # Freeform Tags + Defined Tags. Tags are applied to all resources.
  tag_values = { "freeformTags" = { "Environment" = "Development", "DeploymentType" = "basic", "QuickstartExample" = "basic-cluster" }, "definedTags" = {} }

  # OKE Node Pool 1 arguments
  node_pool_cni_type_1                 = "FLANNEL_OVERLAY" # Use "OCI_VCN_IP_NATIVE" for VCN Native PODs Network. If the node pool 1 uses the OCI_VCN_IP_NATIVE, the cluster will also be configured with same cni
  node_pool_autoscaler_enabled_1       = true
  node_pool_initial_num_worker_nodes_1 = 3                                                                       # Minimum number of nodes in the node pool
  node_pool_max_num_worker_nodes_1     = 10                                                                      # Maximum number of nodes in the node pool
  node_pool_instance_shape_1           = { "instanceShape" = "VM.Standard.E4.Flex", "ocpus" = 2, "memory" = 64 } # If not using a Flex shape, ocpus and memory are ignored
  node_pool_boot_volume_size_in_gbs_1  = 120

  # VCN for OKE arguments
  vcn_cidr_blocks = "10.22.0.0/16"
}
