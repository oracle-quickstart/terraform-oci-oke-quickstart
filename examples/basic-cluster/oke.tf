module "oke-base" {
  source = "github.com/oracle-quickstart/oke-base?ref=0.7.1"

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  region           = var.region

  # Note: Just few arguments are showing here to simplify the basic example. All other argumets are using default values.
  # App Name to identify deployment. Used for naming resources.
  app_name = "Basic"

  # Freeform Tags + Defined Tags. Tags are applied to all resources.
  tag_values = { "freeformTags" = { "Environment" = "Development", "DeploymentType" = "basic" }, "definedTags" = {} }

  # OKE Cluster arguments
  #   cluster_cni_type = "FLANNEL_OVERLAY" # Use "OCI_VCN_IP_NATIVE" for VCN Native PODs Network

  # OKE Node Pool 1 arguments
  #   node_pool_cni_type_1           = "FLANNEL_OVERLAY" # Use "OCI_VCN_IP_NATIVE" for VCN Native PODs Network
  cluster_autoscaler_enabled     = true
  cluster_autoscaler_min_nodes_1 = 3                                                                       # Minimum number of nodes in the node pool
  cluster_autoscaler_max_nodes_1 = 10                                                                      # Maximum number of nodes in the node pool
  num_pool_workers_1             = 3                                                                       # If cluster_autoscaler_enabled=false, will use this for Number of nodes in the node pool
  node_pool_instance_shape_1     = { "instanceShape" = "VM.Standard.E4.Flex", "ocpus" = 2, "memory" = 64 } # If not using a Flex shape, ocpus and memory are ignored

  # VCN for OKE arguments
  vcn_cidr_blocks = "10.20.0.0/16"
}