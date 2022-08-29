# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OKE Variables
variable "oke_cluster_ocid" {
  description = "OKE cluster OCID"
  type        = string
}
variable "oke_cluster_compartment_ocid" {
  description = "Compartment OCID used by the OKE Cluster"
  type        = string
}

## App Variables
variable "app_name" {
  default     = "OKE App"
  description = "Application name. Will be used as prefix to identify resources, such as OKE, VCN, ATP, and others"
}
variable "app_deployment_environment" {
  default     = "generic" # e.g.: Development, QA, Stage, ...
  description = "Deployment environment for the freeform tags"
}
variable "app_deployment_type" {
  default     = "generic" # e.g.: App Type 1, App Type 2, Red, Purple, ...
  description = "Deployment type for the freeform tags"
}
variable "deploy_id" {
  default     = ""
  description = "Deployment ID"
}

## Node Pool Variables
variable "k8s_version" {
  description = "Kubernetes version installed on your worker nodes"
  type        = string
  default     = "Latest"
}
variable "node_pool_name" {
  default     = "pool1"
  description = "Name of the node pool"
}
variable "num_pool_workers" {
  default     = 3
  description = "The number of worker nodes in the node pool. If select Cluster Autoscaler, will assume the minimum number of nodes configured"
}
variable "node_pool_shape" {
  default     = "VM.Standard.E4.Flex"
  description = "A shape is a template that determines the number of OCPUs, amount of memory, and other resources allocated to a newly created instance for the Worker Node"
}
variable "node_pool_node_shape_config_ocpus" {
  default     = "2" # Only used if flex shape is selected
  description = "You can customize the number of OCPUs to a flexible shape"
}
variable "node_pool_node_shape_config_memory_in_gbs" {
  default     = "16" # Only used if flex shape is selected
  description = "You can customize the amount of memory allocated to a flexible shape"
}
variable "image_operating_system" {
  default     = "Oracle Linux"
  description = "The OS/image installed on all nodes in the node pool."
}
variable "image_operating_system_version" {
  default     = "8"
  description = "The OS/image version installed on all nodes in the node pool."
}
variable "node_pool_boot_volume_size_in_gbs" {
  default     = "50"
  description = "Specify a custom boot volume size (in GB)"
}
variable "generate_public_ssh_key" {
  default = true
}
variable "public_ssh_key" {
  default     = ""
  description = "In order to access your private nodes with a public SSH key you will need to set up a bastion host (a.k.a. jump box). If using public nodes, bastion is not needed. Left blank to not import keys."
}

# OKE Network Variables
variable "oke_vcn_nodes_subnet_ocid" {
  default     = ""
  description = "Nodes Subnet OCID used by the OKE Cluster Worker Nodes"
}

# Customer Manager Encryption Keys
variable "oci_vault_key_id_oke_node_boot_volume" {
  description = "OCI Vault Key OCID used to encrypt the OKE node boot volume"
  type        = string
  default     = null
}

# OCI Provider
variable "tenancy_ocid" {}

# App Name Locals
locals {
  app_name_normalized = substr(replace(lower(var.app_name), " ", "-"), 0, 6)
}

# Deployment Details
variable "app_details" {
  description = "App Details"
}

# Deployment Tags
locals {
  freeform_deployment_tags = {
    "DeploymentID" = "${var.app_details.app_deployment_id}",
    "AppName"      = "${var.app_details.app_name}",
    "Environment"  = "${var.app_details.app_deployment_environment}",
  "DeploymentType" = "${var.app_details.app_deployment_type}" }
}