# Copyright (c) 2023 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

module "oke-quickstart" {
  source = "github.com/oracle-quickstart/terraform-oci-oke-quickstart?ref=0.8.15"

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  region           = var.region

  # Note: Just few arguments are showing here to simplify the basic example. All other arguments are using default values.
  # App Name to identify deployment. Used for naming resources.
  app_name = "Basic with Existent Network"

  # Freeform Tags + Defined Tags. Tags are applied to all resources.
  tag_values = { "freeformTags" = { "Environment" = "Development", "DeploymentType" = "basic", "QuickstartExample" = "basic-with-existing-network" }, "definedTags" = {} }

  # OKE Node Pool 1 arguments
  node_pool_cni_type_1                 = "FLANNEL_OVERLAY" # Use "OCI_VCN_IP_NATIVE" for VCN Native PODs Network. If the node pool 1 uses the OCI_VCN_IP_NATIVE, the cluster will also be configured with same cni
  cluster_autoscaler_enabled           = true
  node_pool_initial_num_worker_nodes_1 = 3                                                                       # Minimum number of nodes in the node pool
  node_pool_max_num_worker_nodes_1     = 10                                                                      # Maximum number of nodes in the node pool
  node_pool_instance_shape_1           = { "instanceShape" = "VM.Standard.E4.Flex", "ocpus" = 2, "memory" = 64 } # If not using a Flex shape, ocpus and memory are ignored

  # VCN for OKE arguments
  create_new_vcn                = false
  existent_vcn_ocid             = "<Existent VCN OCID>" # ocid1.vcn.oc1....
  existent_vcn_compartment_ocid = "" # Optional. Specify if want to create terraform to create the subnets and the VCN is in a different compartment than the OKE cluster

  # Subnet for OKE arguments
  create_subnets                                     = false
  existent_oke_k8s_endpoint_subnet_ocid              = "<Existent Kubernetes API Endpoint Subnet>" # ocid1.subnet....
  existent_oke_nodes_subnet_ocid                     = "<Existent Worker Nodes Subnet>" # ocid1.subnet....
  existent_oke_load_balancer_subnet_ocid             = "<Existent Load Balancer Subnet>" # ocid1.subnet....
  existent_oke_vcn_native_pod_networking_subnet_ocid = "" # Optional. Existent VCN Native POD Networking subnet if the CNI Type is "OCI_VCN_IP_NATIVE"
}
