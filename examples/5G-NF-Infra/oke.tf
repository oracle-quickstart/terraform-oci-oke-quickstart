# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

################################################################################
# OKE Cluster
################################################################################
module "oke-quickstart" {
  source = "github.com/oracle-quickstart/terraform-oci-oke-quickstart?ref=0.8.11"

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  region           = var.region

  # Note: Just few arguments are showing here to simplify the basic example. All other arguments are using default values.
  # App Name to identify deployment. Used for naming resources.
  app_name = "Dev 5G NF Example"

  # Freeform Tags + Defined Tags. Tags are applied to all resources.
  tag_values = { "freeformTags" = { "Environment" = "Development", "DeploymentType" = "5G example", "QuickstartExample" = "5G-NF-Infra" }, "definedTags" = {} }

  # VCN for OKE arguments
  vcn_cidr_blocks      = var.vcn_cidr_blocks
  extra_security_lists = local.extra_security_lists
  extra_subnets        = local.extra_subnets

  # OKE Node Pool 1 arguments
  node_pool_cni_type_1                 = "OCI_VCN_IP_NATIVE" # Use "FLANNEL_OVERLAY" for overlay network or "OCI_VCN_IP_NATIVE" for VCN Native PODs Network. If the node pool 1 uses the OCI_VCN_IP_NATIVE, the cluster will also be configured with same cni
  cluster_autoscaler_enabled           = true
  node_pool_name_1                     = "pool1"
  node_pool_initial_num_worker_nodes_1 = var.node_pool_initial_num_worker_nodes_1 # Minimum number of nodes in the node pool
  node_pool_max_num_worker_nodes_1     = var.node_pool_max_num_worker_nodes_1     # Maximum number of nodes in the node pool
  node_pool_instance_shape_1           = var.node_pool_instance_shape_1
  extra_initial_node_labels_1          = [{ key = "cnf", value = "amf01" }] # Extra initial node labels for node pool 1. Example: "[{ key = "app.something/key1", value = "value1" }]"
  node_pool_cloud_init_parts_1 = [{
    content_type = "text/cloud-config"
    content      = <<EOF
#cloud-config
runcmd:
 - echo "Running prep scripts..."
 - echo "Finished prep scripts."
 - echo "Starting App..."

final_message: "The system is finally up, after $UPTIME seconds"
output: {all: '| tee -a /tmp/cloud-init-output.log'}
EOF
    filename     = "cloud-config.yaml"
  }]

  # Extra Security Lists
  extra_security_list_name_for_nodes                     = "5g_for_pods_security_list" # ["5g_for_pods_security_list", "5g_sctp_security_list"]
  extra_security_list_name_for_vcn_native_pod_networking = "5g_for_pods_security_list" # ["5g_for_pods_security_list", "5g_sctp_security_list"]

  # Cluster Tools
  # ingress_nginx_enabled = true
  # cert_manager_enabled  = true
}
