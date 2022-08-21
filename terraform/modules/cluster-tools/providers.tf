# Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

terraform {
  required_version = ">= 1.1"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.88.1"
      # https://registry.terraform.io/providers/oracle/oci/4.88.1
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12.1"
      # https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
      # https://registry.terraform.io/providers/hashicorp/helm/2.6.0
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.1"
      # https://registry.terraform.io/providers/hashicorp/tls/4.0.1
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.3"
      # https://registry.terraform.io/providers/hashicorp/local/2.2.3
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.2"
      # https://registry.terraform.io/providers/hashicorp/random/3.3.2
    }
  }
}