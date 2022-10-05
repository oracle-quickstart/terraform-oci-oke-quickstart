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


# App defaults

variable "app_name" {
  default     = "K8s App"
  description = "Application name. Will be used as prefix to identify resources, such as OKE, VCN, ATP, and others"
}
variable "tag_values" {
  type = map(any)
  default = { "freeformTags" = {
    "Environment" = "Development",  # e.g.: Demo, Sandbox, Development, QA, Stage, ...
    "DeploymentType" = "generic" }, # e.g.: App Type 1, App Type 2, Red, Purple, ...
  "definedTags" = {} }
  description = "Use Tagging to add metadata to resources. All resources created by this stack will be tagged with the selected tag values."
}
