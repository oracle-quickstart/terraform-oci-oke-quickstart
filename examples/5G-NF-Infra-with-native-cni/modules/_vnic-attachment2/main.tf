# 5G NF VNICs attachments for each node in the node pool
resource "oci_core_vnic_attachment" "vnic_attachment_5gc_oam" {
  create_vnic_details {
    display_name  = "5GC-OAM vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(var.network_cidrs, "SUBNET-5GC-OAM-CIDR"), hostnum)][index(var.node_pool_nodes.*.id, var.node_pool_node_id)]
    subnet_id     = var.subnets["5GC_OAM_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5GC-OAM" }
  }
  instance_id = var.node_pool_node_id
}
resource "oci_core_vnic_attachment" "vnic_attachment_5gc_signalling" {
  create_vnic_details {
    display_name  = "5GC-Signalling vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(var.network_cidrs, "SUBNET-5GC-SIGNALLING-CIDR"), hostnum)][index(var.node_pool_nodes.*.id, var.node_pool_node_id)]
    subnet_id     = var.subnets["5GC_Signalling_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5GC-Signalling" }
  }
  instance_id = var.node_pool_node_id
}
resource "oci_core_vnic_attachment" "vnic_attachment_5g_ran" {
  create_vnic_details {
    display_name  = "5G RAN vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(var.network_cidrs, "SUBNET-5G-RAN-CIDR"), hostnum)][index(var.node_pool_nodes.*.id, var.node_pool_node_id)]
    subnet_id     = var.subnets["5G_RAN_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5G RAN" }
  }
  instance_id = var.node_pool_node_id
}
resource "oci_core_vnic_attachment" "vnic_attachment_5g_legal_intercept" {
  create_vnic_details {
    display_name  = "5G Legal Intercept vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(var.network_cidrs, "SUBNET-LEGAL-INTERCEPT-CIDR"), hostnum)][index(var.node_pool_nodes.*.id, var.node_pool_node_id)]
    subnet_id     = var.subnets["Legal_Intercept_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5G Legal Intercept" }
  }
  instance_id = var.node_pool_node_id
}
resource "oci_core_vnic_attachment" "vnic_attachment_5g_epc" {
  create_vnic_details {
    display_name  = "5G-EPC vnic"
    private_ip    = [for hostnum in range(4, 15) : cidrhost(lookup(var.network_cidrs, "SUBNET-5G-EPC-CIDR"), hostnum)][index(var.node_pool_nodes.*.id, var.node_pool_node_id)]
    subnet_id     = var.subnets["5G_EPC_subnet"].subnet_id
    defined_tags  = {}
    freeform_tags = { "Network" : "5G-EPC" }
  }
  instance_id = var.node_pool_node_id
}
