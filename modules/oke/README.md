

## How to use this Module

Each Module has the following folder structure:

- [modules](https://github.com/oracle-quickstart/oke-base/tree/master/modules): This folder contains the reusable
  code for this Module, broken down into one or more submodules.
<!-- - [examples](https://github.com/oracle-quickstart/oke-base/tree/master/examples): This folder contains examples
  of how to use the submodules.
- [test](https://github.com/oracle-quickstart/oke-base/tree/master/test): Automated tests for the submodules and
  examples. -->

## What's a Terraform Module?

A Terraform Module refers to a self-contained packages of Terraform configurations that are managed as a group. This repo
is a Terraform Module and contains many "submodules" which can be composed together to create useful infrastructure patterns.

## Which projects use this Module?

- [oci-cloudnative (MuShop)](https://github.com/oracle-quickstart/oci-cloudnative): This project is a reference
  implementation of a cloud native microservices application on Oracle Cloud Infrastructure (OCI). It is a
  multi-tiered application that demonstrates how to build and deploy a cloud native application on OCI using
  Kubernetes, Docker, Istio, and other open source technologies.

- [oke-unreal-pixel-streaming](https://github.com/oracle-quickstart/oke-unreal-pixel-streaming): This project deploys
  a Kubernetes cluster on Oracle Cloud Infrastructure (OCI) and deploys the Unreal Pixel Streaming demo application
  on the cluster.

- [oke-sysdig](https://github.com/oracle-quickstart/oke-sysdig): This project deploy a Sysdig Secure agent on an OKE cluster.

- [oke-snyk](https://github.com/oracle-quickstart/oke-snyk): This project deploy a Snyk agent on an OKE cluster.

- several other projects, samples, demos, and customers quickstarts.