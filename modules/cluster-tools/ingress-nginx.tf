# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 


# Ingress/LoadBalancer variables
variable "ingress_nginx_enabled" {
  default     = true
  description = "Enable Ingress Nginx for Kubernetes Services (This option provision a Load Balancer)"
}
variable "ingress_load_balancer_shape" {
  default     = "flexible" # Flexible, 10Mbps, 100Mbps, 400Mbps or 8000Mps
  description = "Shape that will be included on the Ingress annotation for the OCI Load Balancer creation"
}
variable "ingress_load_balancer_shape_flex_min" {
  default     = "10"
  description = "Enter the minimum size of the flexible shape."
}
variable "ingress_load_balancer_shape_flex_max" {
  default     = "100"
  description = "Enter the maximum size of the flexible shape (Should be bigger than minimum size). The maximum service limit is set by your tenancy limits."
}

## Resource Ingress examples
# variable "ingress_hosts" {
#   default     = ""
#   description = "Enter a valid full qualified domain name (FQDN). You will need to map the domain name to the EXTERNAL-IP address on your DNS provider (DNS Registry type - A). If you have multiple domain names, include separated by comma. e.g.: mushop.example.com,catshop.com"
# }
# variable "ingress_tls" {
#   default     = false
#   description = "If enabled, will generate SSL certificates to enable HTTPS for the ingress using the Certificate Issuer"
# }
# variable "ingress_cluster_issuer" {
#   default     = "letsencrypt-prod"
#   description = "Certificate issuer type. Currently supports the free Let's Encrypt and Self-Signed. Only *letsencrypt-prod* generates valid certificates"
# }
# variable "ingress_email_issuer" {
#   default     = "no-reply@example.cloud"
#   description = "You must replace this email address with your own. The certificate provider will use this to contact you about expiring certificates, and issues related to your account."
# }

# Ingress-NGINX helm chart
## https://kubernetes.github.io/ingress-nginx/
## https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = local.helm_repository.ingress_nginx
  chart      = "ingress-nginx"
  version    = local.helm_repository.ingress_nginx_version
  namespace  = kubernetes_namespace.cluster_tools.id
  wait       = false

  set {
    name  = "controller.metrics.enabled"
    value = true
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/oci-load-balancer-shape"
    value = var.ingress_load_balancer_shape
    type  = "string"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/oci-load-balancer-shape-flex-min"
    value = var.ingress_load_balancer_shape_flex_min
    type  = "string"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/oci-load-balancer-shape-flex-max"
    value = var.ingress_load_balancer_shape_flex_max
    type  = "string"
  }

  count = var.ingress_nginx_enabled ? 1 : 0
}

## Kubernetes Service: ingress-nginx-controller
data "kubernetes_service" "ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace.cluster_tools.id
  }
  depends_on = [helm_release.ingress_nginx]

  count = var.ingress_nginx_enabled ? 1 : 0
}
