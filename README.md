# Provisioning Karpenter using Terraform

## Introduction

Provisioning [Karpenter](https://karpenter.sh/docs/getting-started/) requires a number of manual steps. This repository aims to automate those steps using Terraform

## Prerequisites

You should have the following installed in your machine:

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
* [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
* [ekstcl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) - This is necessary to modify `aws-auth` - Refer to [null-resource](null-resource.tf)

## (Optional) Create Cluster

If you don't already have a cluster, adjust the [cluster definition file](cluster/eks-cluster.yaml) and create one. Else, skip this step.

```bash
eksctl create cluster -f cluster/eks-cluster.yaml
```

## Deploy Karpenter

All the related terraform templates are available in the `karpenter` folder. It contains karpenter provisioner, Bottlerocket launch template and IAM roles, polcies needed for Karpenter.

Adjust variables in [terraform.tfvars](karpenter/terraform.tfvars) and deploy

```bash
cd karpenter
terraform init
terraform apply
```

Deploy the default `Provisioner` manifest file that is created automatically

```bash
kubectl apply -f default-provisioner.yaml
```

## Test with sample application

```bash
kubectl apply -f sample-workload/pause.yaml
```

## Cleanup

To delete the Karpenter, use the following command

```bash
terraform destroy
```

To delete the whole cluster use the following command

```bash
eksctl delete cluster --region=ap-southeast-1 --name=eks-cluster
```

If you face any issues in cleaning up the resource, check the CloudFormation dashboard in the AWS console or delete the appropriate stack from there