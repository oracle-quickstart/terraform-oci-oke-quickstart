# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# OKE Variables
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

## OKE Node Pool Details
variable "oke_node_pools" {
  type = list(any)

  default     = []
  description = "Node pools (id, min_nodes, max_nodes) to use with Cluster Autoscaler"
}
# variable "k8s_version" {
#   default     = "Latest"
#   description = "Kubernetes version installed on your worker nodes"
# }

# OCI Provider
variable "region" {}

# Get OKE options
locals {
  node_pool_k8s_latest_version = reverse(sort(data.oci_containerengine_node_pool_option.node_pool.kubernetes_versions))[0]
}