# Copyright (c) 2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Cert Manager variables
variable "cert_manager_enabled" {
  default     = true
  description = "Enable x509 Certificate Management"
}

# Cert Manager Helm chart
## https://github.com/jetstack/cert-manager/blob/master/README.md
## https://artifacthub.io/packages/helm/cert-manager/cert-manager
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = local.helm_repository.jetstack
  chart      = "cert-manager"
  version    = local.helm_repository.jetstack_version
  namespace  = kubernetes_namespace.cluster_tools.id
  wait       = true # wait to allow the webhook be properly configured

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "webhook.timeoutSeconds"
    value = "30"
  }

  count = var.cert_manager_enabled ? 1 : 0
}