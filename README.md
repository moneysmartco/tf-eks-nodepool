# tf-eks-nodepool
Create a EKS nodepool for existing EKS cluster

## Run with terraform

Update necessary variables and settings in terraform.tfvars following the sample file.

```
## Init the project
terraform init

## Download all remote modules
terrafrom get

## Prepare the output and verify
terraform plan

## Apply to AWS
terraform apply
```
