output "vnic_id" {
  value = [{
    vnic_attachment_5gc_oam            = oci_core_vnic_attachment.vnic_attachment_5gc_oam.*.vnic_id,
    vnic_attachment_5gc_signalling     = oci_core_vnic_attachment.vnic_attachment_5gc_signalling.*.vnic_id,
    vnic_attachment_5g_ran             = oci_core_vnic_attachment.vnic_attachment_5g_ran.*.vnic_id,
    vnic_attachment_5g_legal_intercept = oci_core_vnic_attachment.vnic_attachment_5g_legal_intercept.*.vnic_id,
    vnic_attachment_5g_epc             = oci_core_vnic_attachment.vnic_attachment_5g_epc.*.vnic_id
  }]
}