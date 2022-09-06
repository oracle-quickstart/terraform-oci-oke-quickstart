# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

variable "create_new_subnet" {
  default     = false
  description = "Create a new node pool if true or use an existing one if false"
}

variable "network_cidrs" {
  type = map(string)

  default = {
    EXTRA-SUBNET-REGIONAL-CIDR = "10.20.40.0/24"
    ALL-CIDR                   = "0.0.0.0/0"
  }
}

variable "oke_vcn_ocid" {
  description = "VCN OCID used by the OKE Cluster"
}
variable "oke_vcn_compartment_ocid" {
  description = "VCN Compartment OCID used by the OKE Cluster VCN resources"
}
variable "oke_vcn_default_dhcp_ocid" {
  description = "Default DHCP OCID used by the OKE Cluster VCN"
}
variable "oke_vcn_nat_gateway_ocid" {
  description = "NAT Gateway OCID used by the OKE Cluster VCN"
}
variable "oke_vcn_internet_gateway_ocid" {
  description = "Internet Gateway OCID used by the OKE Cluster VCN"
}
variable "oke_vcn_service_gateway_ocid" {
  description = "Service Gateway OCID used by the OKE Cluster VCN"
}

variable "subnet_name" {
  default     = "Extra Subnet"
  description = "Subnet Name"
}

# Deployment Details + Freeform Tags
variable "freeform_deployment_tags" {
  description = "Tags to be added to the resources"
}

# Subnet Name Locals
locals {
  subnet_name_for_dns    = substr(lower(replace(var.subnet_name, "/\\W|_|\\s/", "")), 0, 6)
  subnet_name_normalized = substr(replace(lower(var.subnet_name), " ", "-"), 0, 6)
  deploy_id              = var.freeform_deployment_tags.DeploymentID
}