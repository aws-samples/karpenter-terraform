# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

resource "helm_release" "karpenter" {
  depends_on = [
    aws_ec2_tag.karpenter_tags
  ]

  namespace        = var.karpenter_namespace
  create_namespace = true

  name       = "karpenter"
  repository = "https://charts.karpenter.sh/"
  chart      = "karpenter"
  version    = var.karpenter_version


  values = [
    templatefile(
      "${path.module}/templates/values.yaml.tpl",
      {
        "karpenter_iam_role"   = module.iam_assumable_role_karpenter.iam_role_arn,
        "cluster_name"         = var.cluster_name,
        "cluster_endpoint"     = data.aws_eks_cluster.eks.endpoint,
        "karpenter_node_group" = var.karpenter_target_nodegroup,
      }
    )
  ]
}

# A default Karpenter Provisioner manifest is created as a sample.
# Provisioner Custom Resource cannot be created at the same time as the CRD, so manifest file is created instead
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1367
resource "local_file" "karpenter_provisioner" {
  content = yamlencode({
    "apiVersion" = "karpenter.sh/v1alpha5"
    "kind"       = "Provisioner"
    "metadata" = {
      "name" = "default"
    }
    "spec" = {
      "labels" = {
        "purpose" = "demo"
      }
      "provider" = {
        "launchTemplate"  = aws_launch_template.bottlerocket.name
        "subnetSelector"  = {
          format("kubernetes.io/cluster/%s", var.cluster_name) = "true"
        }
        "securityGroupSelector"  = {
          format("kubernetes.io/cluster/%s", var.cluster_name) = "owned"
        }
      }
      "requirements" = [
        {
          "key"      = "node.kubernetes.io/instance-type"
          "operator" = "In"
          "values"   = "${var.karpenter_ec2_instance_types}"
        },
        {
          "key"      = "topology.kubernetes.io/zone"
          "operator" = "In"
          "values"   = "${var.karpenter_vpc_az}"
        },
        {
          "key"      = "kubernetes.io/arch"
          "operator" = "In"
          "values"   = "${var.karpenter_ec2_arch}"
        },
        {
          "key"      = "karpenter.sh/capacity-type"
          "operator" = "In"
          "values"   = "${var.karpenter_ec2_capacity_type}"
        },
      ]
      "ttlSecondsAfterEmpty"   = "${var.karpenter_ttl_seconds_after_empty}"
      "ttlSecondsUntilExpired" = "${var.karpenter_ttl_seconds_until_expired}" # 7 days
    }
  })

  filename = "${path.module}/default-provisioner.yaml"
}