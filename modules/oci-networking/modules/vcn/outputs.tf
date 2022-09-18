# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

output "vcn_id" {
  value = var.create_new_vcn ? oci_core_vcn.main[0].id : var.existent_vcn_ocid
}
output "default_dhcp_options_id" {
  value = var.create_new_vcn ? oci_core_vcn.main[0].default_dhcp_options_id : null
}