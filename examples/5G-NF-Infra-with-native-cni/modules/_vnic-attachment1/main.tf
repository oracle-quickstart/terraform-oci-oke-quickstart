# 5G NF VNICs attachments for each node in the node pool
resource "oci_core_vnic_attachment" "vnic_attachment_5gc_oam" {
  # for_each = { for map in var.node_pool_nodes : map.id => map }
  for_each = toset(var.node_pool_nodes.*.id)
  create_vnic_details {
    display_name  = "5GC-OAM vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(var.network_cidrs, "SUBNET-5GC-OAM-CIDR"), hostnum)][index(var.node_pool_nodes.*.id, each.key)]
    subnet_id     = var.subnets["5GC_OAM_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5GC-OAM" }
  }
  # instance_id = each.value.id
  instance_id = each.key
}
resource "oci_core_vnic_attachment" "vnic_attachment_5gc_signalling" {
  for_each = { for map in var.node_pool_nodes : map.id => map }
  create_vnic_details {
    display_name  = "5GC-Signalling vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(var.network_cidrs, "SUBNET-5GC-SIGNALLING-CIDR"), hostnum)][index(var.node_pool_nodes.*.id, each.key)]
    subnet_id     = var.subnets["5GC_Signalling_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5GC-Signalling" }
  }
  instance_id = each.value.id
}
resource "oci_core_vnic_attachment" "vnic_attachment_5g_ran" {
  for_each = { for map in var.node_pool_nodes : map.id => map }
  create_vnic_details {
    display_name  = "5G RAN vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(var.network_cidrs, "SUBNET-5G-RAN-CIDR"), hostnum)][index(var.node_pool_nodes.*.id, each.key)]
    subnet_id     = var.subnets["5G_RAN_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5G RAN" }
  }
  instance_id = each.value.id
}
resource "oci_core_vnic_attachment" "vnic_attachment_5g_legal_intercept" {
  for_each = { for map in var.node_pool_nodes : map.id => map }
  create_vnic_details {
    display_name  = "5G Legal Intercept vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(var.network_cidrs, "SUBNET-LEGAL-INTERCEPT-CIDR"), hostnum)][index(var.node_pool_nodes.*.id, each.key)]
    subnet_id     = var.subnets["Legal_Intercept_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5G Legal Intercept" }
  }
  instance_id = each.value.id
}
resource "oci_core_vnic_attachment" "vnic_attachment_5g_epc" {
  for_each = { for map in var.node_pool_nodes : map.id => map }
  create_vnic_details {
    display_name  = "5G-EPC vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(var.network_cidrs, "SUBNET-5G-EPC-CIDR"), hostnum)][index(var.node_pool_nodes.*.id, each.key)]
    subnet_id     = var.subnets["5G_EPC_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5G-EPC" }
  }
  instance_id = each.value.id
}
