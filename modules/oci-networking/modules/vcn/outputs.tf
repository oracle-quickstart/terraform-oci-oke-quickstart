# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

output "vcn_id" {
  value = data.oci_core_vcn.main_or_existent.id
}
output "default_dhcp_options_id" {
  value = data.oci_core_vcn.main_or_existent.default_dhcp_options_id
}