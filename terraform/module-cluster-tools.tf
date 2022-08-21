# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

module "cluster-tools" {
  source = "./modules/cluster-tools"

  # Oracle Cloud Infrastructure Tenancy and Compartment OCID
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  region           = var.region

  # Cluster Tools
  ## Ingress
  ingress_nginx_enabled                = var.ingress_nginx_enabled
  ingress_load_balancer_shape          = var.ingress_load_balancer_shape
  ingress_load_balancer_shape_flex_min = var.ingress_load_balancer_shape_flex_min
  ingress_load_balancer_shape_flex_max = var.ingress_load_balancer_shape_flex_max

  ## Cert Manager
  cert_manager_enabled = var.cert_manager_enabled

  ## Metrics Server
  metrics_server_enabled = var.metrics_server_enabled

  ## Prometheus
  prometheus_enabled = var.prometheus_enabled

  ## Grafana
  grafana_enabled = var.grafana_enabled

  depends_on = [module.oke]
}

# Kubernetes Cluster Tools
## Ingress/LoadBalancer
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
  default     = "100" # From 10 to 8000. Cannot be lower than flex_min
  description = "Enter the maximum size of the flexible shape (Should be bigger than minimum size). The maximum service limit is set by your tenancy limits."
}

## Cert Manager
variable "cert_manager_enabled" {
  default     = false
  description = "Enable x509 Certificate Management"
}

## Metrics Server
variable "metrics_server_enabled" {
  default     = true
  description = "Enable Metrics Server for Metrics, HPA, VPA and Cluster Autoscaler"
}

## Prometheus
variable "prometheus_enabled" {
  default     = true
  description = "Enable Prometheus"
}

## Grafana
variable "grafana_enabled" {
  default     = false
  description = "Enable Grafana Dashboards. Includes example dashboards and Prometheus, OCI Logging and OCI Metrics datasources"
}
