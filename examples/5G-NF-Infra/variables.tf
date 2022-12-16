# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

################################################################################
# OCI Provider Variables
################################################################################
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}

################################################################################
# Variables: OCI Networking
################################################################################
## VCN
variable "vcn_cidr_blocks" {
  default     = "10.75.0.0/16"
  description = "IPv4 CIDR Blocks for the Virtual Cloud Network (VCN). If use more than one block, separate them with comma. e.g.: 10.20.0.0/16,10.80.0.0/16. If you plan to peer this VCN with another VCN, the VCNs must not have overlapping CIDRs."
}

################################################################################
# Variables: OKE Node Pools
################################################################################
#### Note: ocpus and memory are only used if flex shape is selected
variable "node_pool_instance_shape_1" {
  type = map(any)
  default = {
    "instanceShape" = "VM.Standard3.Flex"
    "ocpus"         = 8 # Minimum 8 OCPUs to match minimum number of VNICs for 5G network
    "memory"        = 96
  }
  description = "Pooll: A shape is a template that determines the number of OCPUs, amount of memory, and other resources allocated to a newly created instance for the Worker Node. Select at least 2 OCPUs and 16GB of memory if using Flex shapes."
}
variable "node_pool_initial_num_worker_nodes_1" {
  default     = 5
  description = "The number of worker nodes in the node pool. If enable Cluster Autoscaler, will assume the minimum number of nodes on the node pool to be scheduled by the Kubernetes (pool1)"
}
variable "node_pool_max_num_worker_nodes_1" {
  default     = 10
  description = "Maximum number of nodes on the node pool to be scheduled by the Kubernetes (pool1)"
}
variable "node_pool_name_1" {
  default     = "pool1"
  description = "Name of the node pool 1"
}