# Copyright (c) 2021, 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OKE Variables
## OKE Cluster Details
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
variable "create_new_oke_cluster" {
  default     = false
  description = "Creates a new OKE cluster and node pool"
}
variable "existent_oke_cluster_id" {
  default     = ""
  description = "Using existent OKE Cluster. Only the application and services will be provisioned. If select cluster autoscaler feature, you need to get the node pool id and enter when required"
}
variable "existent_oke_cluster_private_endpoint" {
  default     = ""
  description = "Resource Manager Private Endpoint to access the OKE Private Cluster"
}
variable "create_new_compartment_for_oke" {
  default     = false
  description = "Creates new compartment for OKE Nodes and OCI Services deployed.  NOTE: The creation of the compartment increases the deployment time by at least 3 minutes, and can increase by 15 minutes when destroying"
}
variable "oke_compartment_description" {
  default = "Compartment for OKE, Nodes and Services"
}
variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {
  default = false
}
variable "cluster_options_admission_controller_options_is_pod_security_policy_enabled" {
  description = "If true: The pod security policy admission controller will use pod security policies to restrict the pods accepted into the cluster."
  default     = false
}

## OKE Visibility (Workers and Endpoint)

variable "cluster_workers_visibility" {
  default     = "Private"
  description = "The Kubernetes worker nodes that are created will be hosted in public or private subnet(s)"

  validation {
    condition     = var.cluster_workers_visibility == "Private" || var.cluster_workers_visibility == "Public"
    error_message = "Sorry, but cluster visibility can only be Private or Public."
  }
}

variable "cluster_endpoint_visibility" {
  default     = "Public"
  description = "The Kubernetes cluster that is created will be hosted on a public subnet with a public IP address auto-assigned or on a private subnet. If Private, additional configuration will be necessary to run kubectl commands"

  validation {
    condition     = var.cluster_endpoint_visibility == "Private" || var.cluster_endpoint_visibility == "Public"
    error_message = "Sorry, but cluster endpoint visibility can only be Private or Public."
  }
}

## OKE Encryption details
variable "oci_vault_key_id_oke_secrets" {
  default     = null
  description = "OCI Vault OCID to encrypt OKE secrets. If not provided, the secrets will be encrypted with the default key"
}
variable "oci_vault_key_id_oke_image_policy" {
  default     = null
  description = "OCI Vault OCID for the Image Policy"
}

variable "create_vault_policies_for_group" {
  default     = false
  description = "Creates policies to allow the user applying the stack to manage vault and keys. If you are on the Administrators group or already have the policies for a compartment, this policy is not needed. If you do not have access to allow the policy, ask your administrator to include it for you"
}
variable "user_admin_group_for_vault_policy" {
  default     = "Administrators"
  description = "User Identity Group to allow manage vault and keys. The user running the Terraform scripts or Applying the ORM Stack need to be on this group"
}

variable "k8s_version" {
  default     = "Latest"
  description = "Kubernetes version installed on your Control Plane"
}

# OCI Provider
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}

# Network Details
## CIDRs
variable "network_cidrs" {
  type = map(string)

  default = {
    VCN-CIDR                      = "10.20.0.0/16"
    SUBNET-REGIONAL-CIDR          = "10.20.10.0/24"
    LB-SUBNET-REGIONAL-CIDR       = "10.20.20.0/24"
    APIGW-FN-SUBNET-REGIONAL-CIDR = "10.20.30.0/24"
    ENDPOINT-SUBNET-REGIONAL-CIDR = "10.20.0.0/28"
    ALL-CIDR                      = "0.0.0.0/0"
    PODS-CIDR                     = "10.244.0.0/16"
    KUBERNETES-SERVICE-CIDR       = "10.96.0.0/16"
  }
}
## VCN
variable "create_new_vcn" {
  default     = false
  description = "Creates a new VCN"
}

# Create Dynamic Group and Policies
variable "create_dynamic_group_for_nodes_in_compartment" {
  default     = false # TODO: true 
  description = "Creates dynamic group of Nodes in the compartment. Note: You need to have proper rights on the Tenancy. If you only have rights in a compartment, uncheck and ask you administrator to create the Dynamic Group for you"
}
variable "existent_dynamic_group_for_nodes_in_compartment" {
  default     = ""
  description = "Enter previous created Dynamic Group for the policies"
}
variable "create_compartment_policies" {
  default     = false # TODO: true 
  description = "Creates policies that will reside on the compartment. e.g.: Policies to support Cluster Autoscaler, OCI Logging datasource on Grafana"
}
variable "create_tenancy_policies" {
  default     = false # TODO: true 
  description = "Creates policies that need to reside on the tenancy. e.g.: Policies to support OCI Metrics datasource on Grafana"
}

# ORM Schema visual control variables
variable "show_advanced" {
  default = false
}

# App Name Locals
locals {
  app_name            = var.freeform_deployment_tags.AppName
  deploy_id           = var.freeform_deployment_tags.DeploymentID
  app_name_normalized = substr(replace(lower(var.freeform_deployment_tags.AppName), " ", "-"), 0, 6)
  app_name_for_dns = substr(lower(replace(var.freeform_deployment_tags.AppName,"/\\W|_|\\s/","")), 0, 6)
}

# OKE Compartment
locals {
  oke_compartment_ocid = var.compartment_ocid
}

# Deployment Details + Freeform Tags
variable "freeform_deployment_tags" {
  description = "Tags to be added to the resources"
}
