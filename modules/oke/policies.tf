# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_identity_dynamic_group" "app_dynamic_group" {
  name           = "${local.app_name_normalized}-dg-${local.deploy_id}"
  description    = "${local.app_name} OKE Cluster Dynamic Group (${local.deploy_id})"
  compartment_id = var.tenancy_ocid
  matching_rule  = "ANY {${join(",", local.dynamic_group_matching_rules)}}"

  provider = oci.home_region

  count = var.create_dynamic_group_for_nodes_in_compartment ? 1 : 0
}
resource "oci_identity_policy" "app_compartment_policies" {
  name           = "${local.app_name_normalized}-compartment-policies-${local.deploy_id}"
  description    = "${local.app_name} OKE Cluster Compartment Policies (${local.deploy_id})"
  compartment_id = local.oke_compartment_ocid
  statements     = local.app_compartment_statements

  depends_on = [oci_identity_dynamic_group.app_dynamic_group]

  provider = oci.home_region

  count = var.create_compartment_policies ? 1 : 0
}

# Concat Matching Rules and Policy Statements
locals {
  dynamic_group_matching_rules = concat(
    local.instances_in_compartment_rule,
    local.clusters_in_compartment_rule
  )
  app_compartment_statements = concat(
    local.oke_cluster_statements
  )
}

# Individual Rules
locals {
  instances_in_compartment_rule = ["ALL {instance.compartment.id = '${local.oke_compartment_ocid}'}"]
  clusters_in_compartment_rule  = ["ALL {resource.type = 'cluster', resource.compartment.id = '${local.oke_compartment_ocid}'}"]
}

# Individual Policy Statements
locals {
  oke_cluster_statements = [
    "Allow dynamic-group ${local.app_dynamic_group} to manage cluster-node-pools in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.app_dynamic_group} to manage instance-family in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.app_dynamic_group} to use subnets in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.app_dynamic_group} to read virtual-network-family in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.app_dynamic_group} to use vnics in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.app_dynamic_group} to inspect compartments in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.app_dynamic_group} to use network-security-groups in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.app_dynamic_group} to use private-ips in compartment id ${local.oke_compartment_ocid}",
    "Allow dynamic-group ${local.app_dynamic_group} to manage public-ips in compartment id ${local.oke_compartment_ocid}"
  ]
}

# Conditional locals
locals {
  app_dynamic_group = var.create_dynamic_group_for_nodes_in_compartment ? oci_identity_dynamic_group.app_dynamic_group.0.name : "void"
}
