# Terraform Scripts for deploying the 5G NF Infra on OCI OKE

## Deploy Using the Terraform CLI

### Clone the Module

Clone the source code from suing the following command:

```bash
git clone github.com/oracle-quickstart/terraform-oci-oke-quickstart
```

```bash
cd terraform-oci-oke-quickstart/examples/5G-NF-Infra
```

### Updating Terraform variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update the `terraform.tfvars` file with the required variables, including the OCI credentials information.

### Running Terraform

After specifying the required variables you can run the stack using the following commands:

```bash
terraform init
```

```bash
terraform plan
```

```bash
terraform apply
```

### Destroying the Stack

```bash
terraform destroy -refresh=false
```

> Note: The `-refresh=false` flag is required to prevent Terraform from attempting to refresh the state of the kubernetes API url, which will return `localhost` without the refresh-false.

### Deploying the demo app

After the infrastructure is deployed, you can deploy the demo app using the following commands:

```bash
TBD
```

## Questions

If you have an issue or a question, please take a look at our [FAQs](../FAQs.md) or [open an issue](https://github.com/oracle-quickstart/terraform-oci-oke-quickstart/issues/new).
