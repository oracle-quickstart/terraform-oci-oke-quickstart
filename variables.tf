# OCI Provider
variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}

variable "app_name" {
  default     = "K8s App"
  description = "Application name. Will be used as prefix to identify resources, such as OKE, VCN, ATP, and others"
}
