# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

module "oke" {
  source = "./modules/oke"

  providers = {
    oci             = oci
    oci.home_region = oci.home_region
  }

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  region           = var.region

  # OKE Cluster
  app_name                   = var.app_name
  app_deployment_environment = var.app_deployment_environment
  app_deployment_type        = var.app_deployment_type

  ## create_new_oke_cluster
  create_new_oke_cluster         = var.create_new_oke_cluster
  existent_oke_cluster_id        = var.existent_oke_cluster_id
  create_new_compartment_for_oke = var.create_new_compartment_for_oke
  oke_compartment_description    = var.oke_compartment_description

  ## Cluster Workers visibility
  cluster_workers_visibility = var.cluster_workers_visibility

  ## Cluster API Endpoint visibility
  cluster_endpoint_visibility = var.cluster_endpoint_visibility

  ## Create Dynamic group and Policies for Autoscaler and OCI Metrics and Logging
  create_dynamic_group_for_nodes_in_compartment = var.create_dynamic_group_for_nodes_in_compartment
  create_compartment_policies                   = var.create_compartment_policies

  ## Encryption (OCI Vault/Key Management/KMS)
  use_encryption_from_oci_vault = var.use_encryption_from_oci_vault
  create_new_encryption_key     = var.create_new_encryption_key
  existent_encryption_key_id    = var.existent_encryption_key_id

  ## Enable Cluster Autoscaler
  cluster_autoscaler_enabled              = var.cluster_autoscaler_enabled
  cluster_autoscaler_min_nodes            = var.cluster_autoscaler_min_nodes
  cluster_autoscaler_max_nodes            = var.cluster_autoscaler_max_nodes
  existent_oke_nodepool_id_for_autoscaler = var.existent_oke_nodepool_id_for_autoscaler

  ## OKE Worker Nodes (Compute)
  num_pool_workers                          = var.num_pool_workers
  node_pool_shape                           = var.node_pool_instance_shape.instanceShape
  node_pool_node_shape_config_ocpus         = var.node_pool_instance_shape.ocpus
  node_pool_node_shape_config_memory_in_gbs = var.node_pool_instance_shape.memory
  generate_public_ssh_key                   = var.generate_public_ssh_key
  public_ssh_key                            = var.public_ssh_key

  # count = var.oke_provision ? 1 : 0
}

# OKE Variables
# variable "oke_provision" {
#   default     = false
#   description = "Provision OCI Container Engine - OKE"
# }
## OKE Cluster Details
variable "app_name" {
  default     = "K8s App"
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
  default     = true
  description = "Creates a new OKE cluster, node pool and network resources"
}
variable "existent_oke_cluster_id" {
  default     = ""
  description = "Using existent OKE Cluster. Only the application and services will be provisioned. If select cluster autoscaler feature, you need to get the node pool id and enter when required"
}
variable "create_new_compartment_for_oke" {
  default     = false
  description = "Creates new compartment for OKE Nodes and OCI Services deployed.  NOTE: The creation of the compartment increases the deployment time by at least 3 minutes, and can increase by 15 minutes when destroying"
}
variable "oke_compartment_description" {
  default = "Compartment for OKE, Nodes and Services"
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

# NOTE: Private Endpoint is only supported when using OCI Resource Manager for deployment.
variable "cluster_endpoint_visibility" {
  default     = "Public"
  description = "The Kubernetes cluster that is created will be hosted on a public subnet with a public IP address auto-assigned or on a private subnet. If Private, additional configuration will be necessary to run kubectl commands"

  validation {
    condition     = var.cluster_endpoint_visibility == "Private" || var.cluster_endpoint_visibility == "Public"
    error_message = "Sorry, but cluster endpoint visibility can only be Private or Public."
  }
}

## OKE Encryption details
variable "use_encryption_from_oci_vault" {
  default     = false
  description = "By default, Oracle manages the keys that encrypts Kubernetes Secrets at Rest in Etcd, but you can choose a key from a vault that you have access to, if you want greater control over the key's lifecycle and how it's used"
}
variable "create_new_encryption_key" {
  default     = false
  description = "Creates new vault and key on OCI Vault/Key Management/KMS and assign to boot volume of the worker nodes"
}
variable "existent_encryption_key_id" {
  default     = ""
  description = "Use an existent master encryption key to encrypt boot volume and object storage bucket. NOTE: If the key resides in a different compartment or in a different tenancy, make sure you have the proper policies to access, or the provision of the worker nodes will fail"
}
variable "create_vault_policies_for_group" {
  default     = false
  description = "Creates policies to allow the user applying the stack to manage vault and keys. If you are on the Administrators group or already have the policies for a compartment, this policy is not needed. If you do not have access to allow the policy, ask your administrator to include it for you"
}
variable "user_admin_group_for_vault_policy" {
  default     = "Administrators"
  description = "User Identity Group to allow manage vault and keys. The user running the Terraform scripts or Applying the ORM Stack need to be on this group"
}

## OKE Autoscaler
variable "cluster_autoscaler_enabled" {
  default     = true
  description = "Enables OKE cluster autoscaler. Node pools will auto scale based on the resources usage"
}
variable "cluster_autoscaler_min_nodes" {
  default     = 3
  description = "Minimum number of nodes on the node pool to be scheduled by the Kubernetes"
}
variable "cluster_autoscaler_max_nodes" {
  default     = 10
  description = "Maximum number of nodes on the node pool to be scheduled by the Kubernetes"
}
variable "existent_oke_nodepool_id_for_autoscaler" {
  default     = ""
  description = "Nodepool Id of the existent OKE to use with Cluster Autoscaler"
}

## OKE Node Pool Details
variable "node_pool_name" {
  default     = "pool1"
  description = "Name of the node pool"
}
variable "k8s_version" {
  default     = "Latest"
  description = "Kubernetes version installed on your master and worker nodes. If not version select, will use the latest available."
}
variable "num_pool_workers" {
  default     = 3
  description = "The number of worker nodes in the node pool. If select Cluster Autoscaler, will assume the minimum number of nodes configured"
}

# ocpus and memory are only used if flex shape is selected
variable "node_pool_instance_shape" {
  type = map(any)
  default = {
    "instanceShape" = "VM.Standard.E4.Flex"
    "ocpus"         = 2
    "memory"        = 16
  }
  description = "A shape is a template that determines the number of OCPUs, amount of memory, and other resources allocated to a newly created instance for the Worker Node. Select at least 2 OCPUs and 16GB of memory if using Flex shapes"
}
# variable "node_pool_node_shape_config_ocpus" {
#   default     = "1" # Only used if flex shape is selected
#   description = "You can customize the number of OCPUs to a flexible shape"
# }
# variable "node_pool_node_shape_config_memory_in_gbs" {
#   default     = "16" # Only used if flex shape is selected
#   description = "You can customize the amount of memory allocated to a flexible shape"
# }
variable "node_pool_boot_volume_size_in_gbs" {
  default     = "60"
  description = "Specify a custom boot volume size (in GB)"
}
variable "image_operating_system" {
  default     = "Oracle Linux"
  description = "The OS/image installed on all nodes in the node pool."
}
variable "image_operating_system_version" {
  default     = "8"
  description = "The OS/image version installed on all nodes in the node pool."
}
variable "generate_public_ssh_key" {
  default = true
}
variable "public_ssh_key" {
  default     = ""
  description = "In order to access your private nodes with a public SSH key you will need to set up a bastion host (a.k.a. jump box). If using public nodes, bastion is not needed. Left blank to not import keys."
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

# OKE Outputs

output "comments" {
  value = module.oke.comments
}
output "deploy_id" {
  value = module.oke.deploy_id
}
output "deployed_oke_kubernetes_version" {
  value = module.oke.deployed_oke_kubernetes_version
}
output "deployed_to_region" {
  value = module.oke.deployed_to_region
}
output "kubeconfig" {
  value = module.oke.kubeconfig
}
output "kubeconfig_for_kubectl" {
  value       = module.oke.kubeconfig_for_kubectl
  description = "If using Terraform locally, this command set KUBECONFIG environment variable to run kubectl locally"
}
output "dev" {
  value = module.oke.dev
}
### Important Security Notice ###
# The private key generated by this resource will be stored unencrypted in your Terraform state file. 
# Use of this resource for production deployments is not recommended. 
# Instead, generate a private key file outside of Terraform and distribute it securely to the system where Terraform will be run.
output "generated_private_key_pem" {
  value     = module.oke.generated_private_key_pem
  sensitive = true
}

# output "oke_debug_oke_private_endpoint" {
#   value = module.oke.oke_debug_oke_private_endpoint
# }
# output "oke_debug_orm_private_endpoint_reachable_ip" {
#   value = module.oke.oke_debug_orm_private_endpoint_reachable_ip
# }
# output "oke_debug_oke_endpoints" {
#   value = module.oke.oke_debug_oke_endpoints
# }

output "debug_k8s_version_calculated" {
  value = module.oke.debug_k8s_version_calculated
}

output "debug_k8s_version_var" {
  value = module.oke.debug_k8s_version_var
}