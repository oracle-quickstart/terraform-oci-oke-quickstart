# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# File Version: 0.8.0

################################################################################
#
#       *** Note: Normally, you should not need to edit this file. ***
#
################################################################################

################################################################################
# Module: OCI Vault (KMS) - Key Management Service to use with OKE
################################################################################
module "vault" {
  source = "./modules/oci-vault-kms"

  providers = {
    oci             = oci
    oci.home_region = oci.home_region
  }

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid = var.tenancy_ocid

  # Deployment Tags + Freeform Tags + Defined Tags
  oci_tag_values = local.oci_tag_values

  # Encryption (OCI Vault/Key Management/KMS)
  use_encryption_from_oci_vault = var.use_encryption_from_oci_vault
  create_new_encryption_key     = var.create_new_encryption_key
  existent_encryption_key_id    = var.existent_encryption_key_id

  # OKE Cluster Details
  oke_cluster_compartment_ocid = local.oke_compartment_ocid

  ## Create Dynamic group and Policies for OCI Vault (Key Management/KMS)
  create_dynamic_group_for_nodes_in_compartment = var.create_dynamic_group_for_nodes_in_compartment
  create_compartment_policies                   = var.create_compartment_policies
  create_vault_policies_for_group               = var.create_vault_policies_for_group
}

################################################################################
# Module: Oracle Container Engine for Kubernetes (OKE) Cluster
################################################################################
module "oke" {
  source = "./modules/oke"

  providers = {
    oci             = oci
    oci.home_region = oci.home_region
  }

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = local.oke_compartment_ocid
  region           = var.region

  # Deployment Tags + Freeform Tags + Defined Tags
  cluster_tags        = local.oci_tag_values
  load_balancers_tags = local.oci_tag_values
  block_volumes_tags  = local.oci_tag_values

  # OKE Cluster
  ## create_new_oke_cluster
  create_new_oke_cluster  = var.create_new_oke_cluster
  existent_oke_cluster_id = var.existent_oke_cluster_id

  ## Network Details
  vcn_id                 = module.vcn.vcn_id
  network_cidrs          = local.network_cidrs
  k8s_endpoint_subnet_id = local.create_subnets ? module.subnets["oke_k8s_endpoint_subnet"].subnet_id : var.existent_oke_k8s_endpoint_subnet_ocid
  lb_subnet_id           = local.create_subnets ? module.subnets["oke_lb_subnet"].subnet_id : var.existent_oke_load_balancer_subnet_ocid
  cni_type               = local.cni_type
  ### Cluster Workers visibility
  cluster_workers_visibility = var.cluster_workers_visibility
  ### Cluster API Endpoint visibility
  cluster_endpoint_visibility = var.cluster_endpoint_visibility

  ## Control Plane Kubernetes Version
  k8s_version = var.k8s_version

  ## Create Dynamic group and Policies for Autoscaler and OCI Metrics and Logging
  create_dynamic_group_for_nodes_in_compartment = var.create_dynamic_group_for_nodes_in_compartment
  create_compartment_policies                   = var.create_compartment_policies

  ## Encryption (OCI Vault/Key Management/KMS)
  oci_vault_key_id_oke_secrets      = module.vault.oci_vault_key_id
  oci_vault_key_id_oke_image_policy = module.vault.oci_vault_key_id
}

################################################################################
# Module: OKE Node Pool
################################################################################
module "oke_node_pool" {
  for_each = { for map in local.node_pools : map.node_pool_name => map }
  source   = "./modules/oke-node-pool"

  # Deployment Tags + Freeform Tags
  node_pools_tags   = local.oci_tag_values
  worker_nodes_tags = local.oci_tag_values

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid = var.tenancy_ocid

  # OKE Cluster Details
  oke_cluster_ocid             = module.oke.oke_cluster_ocid
  oke_cluster_compartment_ocid = local.oke_compartment_ocid
  create_new_node_pool         = var.create_new_oke_cluster

  # OKE Worker Nodes (Compute)
  node_pool_name                            = each.value.node_pool_name
  node_pool_min_nodes                       = each.value.node_pool_min_nodes
  node_pool_max_nodes                       = each.value.node_pool_max_nodes
  node_k8s_version                          = each.value.node_k8s_version
  node_pool_shape                           = each.value.node_pool_shape
  node_pool_shape_specifc_ad                = each.value.node_pool_shape_specifc_ad
  node_pool_node_shape_config_ocpus         = each.value.node_pool_node_shape_config_ocpus
  node_pool_node_shape_config_memory_in_gbs = each.value.node_pool_node_shape_config_memory_in_gbs
  existent_oke_nodepool_id_for_autoscaler   = each.value.existent_oke_nodepool_id_for_autoscaler
  public_ssh_key                            = local.workers_public_ssh_key
  image_operating_system                    = each.value.image_operating_system
  image_operating_system_version            = each.value.image_operating_system_version
  extra_initial_node_labels                 = each.value.extra_initial_node_labels
  cni_type                                  = each.value.cni_type

  # OKE Network Details
  nodes_subnet_id                       = local.create_subnets ? module.subnets["oke_nodes_subnet"].subnet_id : var.existent_oke_nodes_subnet_ocid
  vcn_native_pod_networking_subnet_ocid = each.value.cni_type == "OCI_VCN_IP_NATIVE" ? (local.create_subnets ? module.subnets["oke_pods_network_subnet"].subnet_id : var.existent_oke_vcn_native_pod_networking_subnet_ocid) : ""

  # Encryption (OCI Vault/Key Management/KMS)
  oci_vault_key_id_oke_node_boot_volume = module.vault.oci_vault_key_id
}
locals {
  node_pool_1 = [
    {
      node_pool_name                            = var.node_pool_name_1 != "" ? var.node_pool_name_1 : "pool1" # Must be unique
      node_pool_min_nodes                       = var.node_pool_initial_num_worker_nodes_1
      node_pool_max_nodes                       = var.node_pool_max_num_worker_nodes_1
      node_k8s_version                          = var.k8s_version # TODO: Allow to set different version for each node pool
      node_pool_shape                           = var.node_pool_instance_shape_1.instanceShape
      node_pool_shape_specific_ad               = var.node_pool_shape_specific_ad_1
      node_pool_node_shape_config_ocpus         = var.node_pool_instance_shape_1.ocpus
      node_pool_node_shape_config_memory_in_gbs = var.node_pool_instance_shape_1.memory
      node_pool_boot_volume_size_in_gbs         = var.node_pool_boot_volume_size_in_gbs_1
      existent_oke_nodepool_id_for_autoscaler   = var.existent_oke_nodepool_id_for_autoscaler_1
      image_operating_system                    = var.image_operating_system_1
      image_operating_system_version            = var.image_operating_system_version_1
      extra_initial_node_labels                 = var.extra_initial_node_labels_1
      cni_type                                  = var.node_pool_cni_type_1
    },
  ]
}
# Generate ssh keys to access Worker Nodes, if generate_public_ssh_key=true, applies to the pool
resource "tls_private_key" "oke_worker_node_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
locals {
  workers_public_ssh_key = var.generate_public_ssh_key ? tls_private_key.oke_worker_node_ssh_key.public_key_openssh : var.public_ssh_key
}

################################################################################
# Module: OKE Cluster Autoscaler
################################################################################
module "oke_cluster_autoscaler" {
  source = "./modules/oke-cluster-autoscaler"

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  region = var.region

  ## Enable Cluster Autoscaler
  cluster_autoscaler_enabled = var.cluster_autoscaler_enabled
  oke_node_pools             = values(module.oke_node_pool)

  depends_on = [module.oke, module.oke_node_pool]
}

################################################################################
# Variables: OKE Cluster
################################################################################
## OKE Cluster Details
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
variable "cluster_cni_type" {
  default     = "FLANNEL_OVERLAY"
  description = "The CNI type to use for the cluster. Valid values are: FLANNEL_OVERLAY or OCI_VCN_IP_NATIVE"

  validation {
    condition     = var.cluster_cni_type == "FLANNEL_OVERLAY" || var.cluster_cni_type == "OCI_VCN_IP_NATIVE"
    error_message = "Sorry, but OKE currently only supports FLANNEL_OVERLAY or OCI_VCN_IP_NATIVE CNI types."
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
variable "node_pool_initial_num_worker_nodes_1" {
  default     = 3
  description = "The number of worker nodes in the node pool. If enable Cluster Autoscaler, will assume the minimum number of nodes on the node pool to be scheduled by the Kubernetes (pool1)"
}
variable "node_pool_max_num_worker_nodes_1" {
  default     = 10
  description = "Maximum number of nodes on the node pool to be scheduled by the Kubernetes (pool1)"
}
variable "existent_oke_nodepool_id_for_autoscaler_1" {
  default     = ""
  description = "Nodepool Id of the existent OKE to use with Cluster Autoscaler (pool1)"
}

################################################################################
# Variables: OKE Node Pool 1
################################################################################
## OKE Node Pool Details
variable "k8s_version" {
  default     = "Latest"
  description = "Kubernetes version installed on your Control Plane and worker nodes. If not version select, will use the latest available."
}
### Node Pool 1
variable "node_pool_name_1" {
  default     = "pool1"
  description = "Name of the node pool"
}
variable "extra_initial_node_labels_1" {
  default     = []
  description = "Extra initial node labels to be added to the node pool"
}
variable "node_pool_cni_type_1" {
  default     = "FLANNEL_OVERLAY"
  description = "The CNI type to use for the cluster. Valid values are: FLANNEL_OVERLAY or OCI_VCN_IP_NATIVE"

  validation {
    condition     = var.node_pool_cni_type_1 == "FLANNEL_OVERLAY" || var.node_pool_cni_type_1 == "OCI_VCN_IP_NATIVE"
    error_message = "Sorry, but OKE currently only supports FLANNEL_OVERLAY or OCI_VCN_IP_NATIVE CNI types."
  }
}

#### ocpus and memory are only used if flex shape is selected
variable "node_pool_instance_shape_1" {
  type = map(any)
  default = {
    "instanceShape" = "VM.Standard.E4.Flex"
    "ocpus"         = 2
    "memory"        = 16
  }
  description = "A shape is a template that determines the number of OCPUs, amount of memory, and other resources allocated to a newly created instance for the Worker Node. Select at least 2 OCPUs and 16GB of memory if using Flex shapes"
}
variable "node_pool_shape_specific_ad_1" {
  description = "The number of the AD to get the shape for the node pool"
  type        = number
  default     = 0

  validation {
    condition     = var.node_pool_shape_specific_ad_1 >= 0 && var.node_pool_shape_specific_ad_1 <= 3
    error_message = "Invalid AD number, should be 0 to get all ADs or 1, 2 or 3 to be a specific AD."
  }
}
variable "node_pool_boot_volume_size_in_gbs_1" {
  default     = "60"
  description = "Specify a custom boot volume size (in GB)"
}
variable "image_operating_system_1" {
  default     = "Oracle Linux"
  description = "The OS/image installed on all nodes in the node pool."
}
variable "image_operating_system_version_1" {
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

################################################################################
# Variables: Dynamic Group and Policies for OKE
################################################################################
# Create Dynamic Group and Policies
variable "create_dynamic_group_for_nodes_in_compartment" {
  default     = true
  description = "Creates dynamic group of Nodes in the compartment. Note: You need to have proper rights on the Tenancy. If you only have rights in a compartment, uncheck and ask you administrator to create the Dynamic Group for you"
}
variable "existent_dynamic_group_for_nodes_in_compartment" {
  default     = ""
  description = "Enter previous created Dynamic Group for the policies"
}
variable "create_compartment_policies" {
  default     = true
  description = "Creates policies that will reside on the compartment. e.g.: Policies to support Cluster Autoscaler, OCI Logging datasource on Grafana"
}

resource "oci_identity_compartment" "oke_compartment" {
  compartment_id = var.compartment_ocid
  name           = "${local.app_name_normalized}-${local.deploy_id}"
  description    = "${local.app_name} ${var.oke_compartment_description} (Deployment ${local.deploy_id})"
  enable_delete  = true

  count = var.create_new_compartment_for_oke ? 1 : 0
}
locals {
  oke_compartment_ocid = var.create_new_compartment_for_oke ? oci_identity_compartment.oke_compartment.0.id : var.compartment_ocid
}

# Available OCI Services
data "oci_core_services" "all_services_network" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

################################################################################
# Variables: OKE Network
################################################################################
# OKE Network Visibility (Workers, Endpoint and Load Balancers)
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
variable "cluster_load_balancer_visibility" {
  default     = "Public"
  description = "The Load Balancer that is created will be hosted on a public subnet with a public IP address auto-assigned or on a private subnet. This affects the Kubernetes services, ingress controller and other load balancers resources"

  validation {
    condition     = var.cluster_load_balancer_visibility == "Private" || var.cluster_load_balancer_visibility == "Public"
    error_message = "Sorry, but cluster load balancer visibility can only be Private or Public."
  }
}
variable "pods_network_visibility" {
  default     = "Public"
  description = "The PODs that are created will be hosted on a public subnet with a public IP address auto-assigned or on a private subnet. This affects the Kubernetes services and pods"

  validation {
    condition     = var.pods_network_visibility == "Private" || var.pods_network_visibility == "Public"
    error_message = "Sorry, but PODs Network visibility can only be Private or Public."
  }
}

# OKE Network Resources
## Subnets
# VCN Variables
variable "create_subnets" {
  default     = true
  description = "Create subnets for OKE: Endpoint, Nodes, Load Balancers. If CNI Type OCI_VCN_IP_NATIVE, also creates the PODs VCN. If FSS Mount Targets, also creates the FSS Mount Targets Subnet"
}
variable "create_pod_network_subnet" {
  default     = false
  description = "Create PODs Network subnet for OKE. To be used with CNI Type OCI_VCN_IP_NATIVE"
}
variable "existent_oke_k8s_endpoint_subnet_ocid" {
  default     = ""
  description = "The OCID of the subnet where the Kubernetes cluster endpoint will be hosted"
}
variable "existent_oke_nodes_subnet_ocid" {
  default     = ""
  description = "The OCID of the subnet where the Kubernetes worker nodes will be hosted"
}
variable "existent_oke_load_balancer_subnet_ocid" {
  default     = ""
  description = "The OCID of the subnet where the Kubernetes load balancers will be hosted"
}
variable "existent_oke_vcn_native_pod_networking_subnet_ocid" {
  default     = ""
  description = "The OCID of the subnet where the Kubernetes VCN Native Pod Networking will be hosted"
}
variable "existent_oke_fss_mount_targets_subnet_ocid" {
  default     = ""
  description = "The OCID of the subnet where the Kubernetes FSS mount targets will be hosted"
}
# variable "existent_apigw_fn_subnet_ocid" {
#   default     = ""
#   description = "The OCID of the subnet where the API Gateway and Functions will be hosted"
# }


# OKE Subnets definitions
locals {
  subnets_oke = concat(local.subnets_oke_standard, local.subnet_vcn_native_pod_networking, local.subnet_bastion, local.subnet_fss_mount_targets)
  subnets_oke_standard = [
    {
      subnet_name                = "oke_k8s_endpoint_subnet"
      cidr_block                 = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
      display_name               = "OKE K8s Endpoint subnet (${local.deploy_id})"
      dns_label                  = "okek8s${local.deploy_id}"
      prohibit_public_ip_on_vnic = (var.cluster_endpoint_visibility == "Private") ? true : false
      prohibit_internet_ingress  = (var.cluster_endpoint_visibility == "Private") ? true : false
      route_table_id             = (var.cluster_endpoint_visibility == "Private") ? module.route_tables["private"].route_table_id : module.route_tables["public"].route_table_id
      dhcp_options_id            = module.vcn.default_dhcp_options_id
      security_list_ids          = [module.security_lists["oke_endpoint_security_list"].security_list_id]
      ipv6cidr_block             = null
    },
    {
      subnet_name                = "oke_nodes_subnet"
      cidr_block                 = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
      display_name               = "OKE Nodes subnet (${local.deploy_id})"
      dns_label                  = "okenodes${local.deploy_id}"
      prohibit_public_ip_on_vnic = (var.cluster_workers_visibility == "Private") ? true : false
      prohibit_internet_ingress  = (var.cluster_workers_visibility == "Private") ? true : false
      route_table_id             = (var.cluster_workers_visibility == "Private") ? module.route_tables["private"].route_table_id : module.route_tables["public"].route_table_id
      dhcp_options_id            = module.vcn.default_dhcp_options_id
      security_list_ids          = [module.security_lists["oke_nodes_security_list"].security_list_id]
      ipv6cidr_block             = null
    },
    {
      subnet_name                = "oke_lb_subnet"
      cidr_block                 = lookup(local.network_cidrs, "LB-REGIONAL-SUBNET-CIDR")
      display_name               = "OKE LoadBalancers subnet (${local.deploy_id})"
      dns_label                  = "okelb${local.deploy_id}"
      prohibit_public_ip_on_vnic = (var.cluster_load_balancer_visibility == "Private") ? true : false
      prohibit_internet_ingress  = (var.cluster_load_balancer_visibility == "Private") ? true : false
      route_table_id             = (var.cluster_load_balancer_visibility == "Private") ? module.route_tables["private"].route_table_id : module.route_tables["public"].route_table_id
      dhcp_options_id            = module.vcn.default_dhcp_options_id
      security_list_ids          = [module.security_lists["oke_lb_security_list"].security_list_id]
      ipv6cidr_block             = null
    }
  ]
  subnet_vcn_native_pod_networking = (var.create_pod_network_subnet || var.cluster_cni_type == "OCI_VCN_IP_NATIVE" || var.node_pool_cni_type_1 == "OCI_VCN_IP_NATIVE") ? [
    {
      subnet_name                = "oke_pods_network_subnet"
      cidr_block                 = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR") # e.g.: 10.20.128.0/17 (1,1) = 32766 usable IPs (10.20.128.0 - 10.20.255.255)
      display_name               = "OKE PODs Network subnet (${local.deploy_id})"
      dns_label                  = "okenpn${local.deploy_id}"
      prohibit_public_ip_on_vnic = (var.pods_network_visibility == "Private") ? true : false
      prohibit_internet_ingress  = (var.pods_network_visibility == "Private") ? true : false
      route_table_id             = (var.pods_network_visibility == "Private") ? module.route_tables["private"].route_table_id : module.route_tables["public"].route_table_id
      dhcp_options_id            = module.vcn.default_dhcp_options_id
      security_list_ids          = [module.security_lists["oke_pod_network_security_list"].security_list_id]
      ipv6cidr_block             = null
  }] : []
  subnet_bastion           = []
  subnet_fss_mount_targets = [] # 10.20.20.64/26 (10,81) = 62 usable IPs (10.20.20.64 - 10.20.20.255)
}

# OKE Route Tables definitions
locals {
  route_tables_oke = [
    {
      route_table_name = "private"
      display_name     = "OKE Private Route Table (${local.deploy_id})"
      route_rules = [
        {
          description       = "Traffic to the internet"
          destination       = lookup(local.network_cidrs, "ALL-CIDR")
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.gateways.nat_gateway_id
        },
        {
          description       = "Traffic to OCI services"
          destination       = lookup(data.oci_core_services.all_services_network.services[0], "cidr_block")
          destination_type  = "SERVICE_CIDR_BLOCK"
          network_entity_id = module.gateways.service_gateway_id
      }]

    },
    {
      route_table_name = "public"
      display_name     = "OKE Public Route Table (${local.deploy_id})"
      route_rules = [
        {
          description       = "Traffic to/from internet"
          destination       = lookup(local.network_cidrs, "ALL-CIDR")
          destination_type  = "CIDR_BLOCK"
          network_entity_id = module.gateways.internet_gateway_id
      }]
  }]
}

# OKE Security Lists definitions
locals {
  security_lists_oke = [
    {
      security_list_name = "oke_nodes_security_list"
      display_name       = "OKE Node Workers Security List (${local.deploy_id})"
      egress_security_rules = [
        {
          description      = "Allows communication from (or to) worker nodes"
          destination      = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.all_protocols
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Allow worker nodes to communicate with pods on other worker nodes (when using VCN-native pod networking)"
          destination      = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.all_protocols
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "(optional) Allow worker nodes to communicate with internet"
          destination      = lookup(local.network_cidrs, "ALL-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.all_protocols
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
          destination      = lookup(data.oci_core_services.all_services_network.services[0], "cidr_block")
          destination_type = "SERVICE_CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "ICMP Access from Kubernetes Control Plane"
          destination      = lookup(local.network_cidrs, "ALL-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.icmp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = { type = "3", code = "4" }
          }, {
          description      = "Access to Kubernetes API Endpoint"
          destination      = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.k8s_api_endpoint_port_number, min = local.security_list_ports.k8s_api_endpoint_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Kubernetes worker to control plane communication"
          destination      = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.k8s_worker_to_control_plane_port_number, min = local.security_list_ports.k8s_worker_to_control_plane_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Path discovery"
          destination      = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.icmp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = { type = "3", code = "4" }
      }]
      ingress_security_rules = [
        {
          description  = "Allows communication from (or to) worker nodes"
          source       = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.all_protocols
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Allow pods on one worker node to communicate with pods on other worker nodes (when using VCN-native pod networking)"
          source       = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.all_protocols
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "(optional) Allow inbound SSH traffic to worker nodes"
          source       = lookup(local.network_cidrs, (var.cluster_workers_visibility == "Private") ? "VCN-MAIN-CIDR" : "ALL-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.ssh_port_number, min = local.security_list_ports.ssh_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Allow control plane to communicate with worker nodes"
          source       = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Kubernetes API endpoint to worker node communication (when using VCN-native pod networking)"
          source       = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.k8s_api_endpoint_to_worker_port_number, min = local.security_list_ports.k8s_api_endpoint_to_worker_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Path discovery"
          source       = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.icmp_protocol_number
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = { type = "3", code = "4" }
          }, {
          description  = "Load Balancer to Worker nodes node ports"
          source       = lookup(local.network_cidrs, "LB-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number # all_protocols
          stateless    = false
          tcp_options  = { max = 32767, min = 30000, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
      }]
    },
    {
      security_list_name = "oke_lb_security_list"
      display_name       = "OKE Load Balancer Security List (${local.deploy_id})"
      egress_security_rules = [
        {
          description      = "Allow traffic to worker nodes"
          destination      = lookup(local.network_cidrs, "ALL-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number # all_protocols
          stateless        = false
          tcp_options      = { max = 32767, min = 30000, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
      }]
      ingress_security_rules = [
        {
          description  = "Allow inbound traffic to Load Balancer"
          source       = lookup(local.network_cidrs, "ALL-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.https_port_number, min = local.security_list_ports.https_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
      }]
    },
    {
      security_list_name = "oke_endpoint_security_list"
      display_name       = "OKE K8s API Endpoint Security List (${local.deploy_id})"
      egress_security_rules = [
        {
          description      = "Allow Kubernetes API Endpoint to communicate with OKE"
          destination      = lookup(data.oci_core_services.all_services_network.services[0], "cidr_block")
          destination_type = "SERVICE_CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.https_port_number, min = local.security_list_ports.https_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Path discovery"
          destination      = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.icmp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = { type = "3", code = "4" }
          }, {
          description      = "All traffic to worker nodes (when using flannel for pod networking)"
          destination      = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Kubernetes API endpoint to pod communication (when using VCN-native pod networking)"
          destination      = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.all_protocols
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Kubernetes API endpoint to worker node communication (when using VCN-native pod networking)"
          destination      = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.k8s_api_endpoint_to_worker_port_number, min = local.security_list_ports.k8s_api_endpoint_to_worker_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
      }]
      ingress_security_rules = [
        {
          description  = "(optional) Client access to Kubernetes API endpoint"
          source       = lookup(local.network_cidrs, (var.cluster_endpoint_visibility == "Private") ? "VCN-MAIN-CIDR" : "ALL-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.k8s_api_endpoint_port_number, min = local.security_list_ports.k8s_api_endpoint_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Kubernetes worker to Kubernetes API endpoint communication"
          source       = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.k8s_api_endpoint_port_number, min = local.security_list_ports.k8s_api_endpoint_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Kubernetes worker to control plane communication"
          source       = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.k8s_worker_to_control_plane_port_number, min = local.security_list_ports.k8s_worker_to_control_plane_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Path discovery"
          source       = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.icmp_protocol_number
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = { type = "3", code = "4" }
          }, {
          description  = "Pod to Kubernetes API endpoint communication (when using VCN-native pod networking)"
          source       = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.k8s_api_endpoint_port_number, min = local.security_list_ports.k8s_api_endpoint_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Pod to control plane communication (when using VCN-native pod networking)"
          source       = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.tcp_protocol_number
          stateless    = false
          tcp_options  = { max = local.security_list_ports.k8s_worker_to_control_plane_port_number, min = local.security_list_ports.k8s_worker_to_control_plane_port_number, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
      }]
    },
    {
      security_list_name = "oke_pod_network_security_list"
      display_name       = "OKE VCN Native Pod Networking Security List (${local.deploy_id})"
      egress_security_rules = [
        {
          description      = "Allow pods to communicate with each other"
          destination      = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.all_protocols
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Path discovery"
          destination      = lookup(data.oci_core_services.all_services_network.services[0], "cidr_block")
          destination_type = "SERVICE_CIDR_BLOCK"
          protocol         = local.security_list_ports.icmp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = { type = "3", code = "4" }
          }, {
          description      = "Allow worker nodes to communicate with OCI services"
          destination      = lookup(data.oci_core_services.all_services_network.services[0], "cidr_block")
          destination_type = "SERVICE_CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = -1, min = -1, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Pod to Kubernetes API endpoint communication (when using VCN-native pod networking)"
          destination      = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.k8s_api_endpoint_port_number, min = local.security_list_ports.k8s_api_endpoint_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "Pod to Kubernetes API endpoint communication (when using VCN-native pod networking)"
          destination      = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.k8s_worker_to_control_plane_port_number, min = local.security_list_ports.k8s_worker_to_control_plane_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
          }, {
          description      = "(optional) Allow pods to communicate with internet"
          destination      = lookup(local.network_cidrs, "ALL-CIDR")
          destination_type = "CIDR_BLOCK"
          protocol         = local.security_list_ports.tcp_protocol_number
          stateless        = false
          tcp_options      = { max = local.security_list_ports.https_port_number, min = local.security_list_ports.https_port_number, source_port_range = null }
          udp_options      = { max = -1, min = -1, source_port_range = null }
          icmp_options     = null
      }]
      ingress_security_rules = [
        {
          description  = "Kubernetes API endpoint to pod communication (when using VCN-native pod networking)"
          source       = lookup(local.network_cidrs, "ENDPOINT-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.all_protocols
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Allow pods on one worker node to communicate with pods on other worker nodes"
          source       = lookup(local.network_cidrs, "NODES-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.all_protocols
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
          }, {
          description  = "Allow pods to communicate with each other"
          source       = lookup(local.network_cidrs, "VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR")
          source_type  = "CIDR_BLOCK"
          protocol     = local.security_list_ports.all_protocols
          stateless    = false
          tcp_options  = { max = -1, min = -1, source_port_range = null }
          udp_options  = { max = -1, min = -1, source_port_range = null }
          icmp_options = null
      }]
    }
  ]
  security_list_ports = {
    http_port_number                        = 80
    https_port_number                       = 443
    k8s_api_endpoint_port_number            = 6443
    k8s_api_endpoint_to_worker_port_number  = 10250
    k8s_worker_to_control_plane_port_number = 12250
    ssh_port_number                         = 22
    tcp_protocol_number                     = "6"
    icmp_protocol_number                    = "1"
    all_protocols                           = "all"
  }
}

# Network locals
locals {
  network_cidrs = {
    VCN-MAIN-CIDR                                  = local.vcn_cidr_blocks[0]                     # e.g.: "10.20.0.0/16" = 65536 usable IPs
    ENDPOINT-REGIONAL-SUBNET-CIDR                  = cidrsubnet(local.vcn_cidr_blocks[0], 12, 0)  # e.g.: "10.20.0.0/28" = 15 usable IPs
    NODES-REGIONAL-SUBNET-CIDR                     = cidrsubnet(local.vcn_cidr_blocks[0], 6, 3)   # e.g.: "10.20.12.0/22" = 1021 usable IPs (10.20.12.0 - 10.20.15.255)
    LB-REGIONAL-SUBNET-CIDR                        = cidrsubnet(local.vcn_cidr_blocks[0], 6, 4)   # e.g.: "10.20.16.0/22" = 1021 usable IPs (10.20.16.0 - 10.20.19.255)
    FSS-MOUNT-TARGETS-REGIONAL-SUBNET-CIDR         = cidrsubnet(local.vcn_cidr_blocks[0], 10, 81) # e.g.: "10.20.20.64/26" = 62 usable IPs (10.20.20.64 - 10.20.20.255)
    APIGW-FN-REGIONAL-SUBNET-CIDR                  = cidrsubnet(local.vcn_cidr_blocks[0], 8, 30)  # e.g.: "10.20.30.0/24" = 254 usable IPs (10.20.30.0 - 10.20.30.255)
    VCN-NATIVE-POD-NETWORKING-REGIONAL-SUBNET-CIDR = cidrsubnet(local.vcn_cidr_blocks[0], 1, 1)   # e.g.: "10.20.128.0/17" = 32766 usable IPs (10.20.128.0 - 10.20.255.255)
    BASTION-REGIONAL-SUBNET-CIDR                   = cidrsubnet(local.vcn_cidr_blocks[0], 12, 32) # e.g.: "10.20.2.0/28" = 15 usable IPs (10.20.2.0 - 10.20.2.15)
    PODS-CIDR                                      = "10.244.0.0/16"
    KUBERNETES-SERVICE-CIDR                        = "10.96.0.0/16"
    ALL-CIDR                                       = "0.0.0.0/0"
  }
  cni_type = (var.cluster_cni_type == "OCI_VCN_IP_NATIVE" || var.node_pool_cni_type_1 == "OCI_VCN_IP_NATIVE") ? "OCI_VCN_IP_NATIVE" : "FLANNEL_OVERLAY"
}
