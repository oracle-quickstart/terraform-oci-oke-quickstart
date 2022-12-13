variable "network_cidrs" {
  description = "IPv4 CIDR Blocks to be used by the vnic attachments"
}
variable "node_pool_nodes" {
  type = list(object({
    availability_domain = string
    defined_tags        = map(any)
    error               = list(any)
    fault_domain        = string
    freeform_tags       = map(any)
    id                  = string
    kubernetes_version  = string
    lifecycle_details   = string
    name                = string
    node_pool_id        = string
    private_ip          = string
    public_ip           = string
    state               = string
    subnet_id           = string
  }))
  description = "Node pool nodes information to be used by the vnic attachments"
}
variable "subnets" {
  description = "Subnets information to be used by the vnic attachments"
}