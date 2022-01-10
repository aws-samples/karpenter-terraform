# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Adjust to your own cluster and nodegroup name
cluster_name               = "eks-cluster"
karpenter_target_nodegroup = "pri-ng"

karpenter_namespace = "karpenter"
karpenter_version   = "0.5.4"

# The variables below are used for the default Karpenter Provisioner that is deployed in this script
karpenter_ec2_instance_types = [
  "t3.large",
  "t3.medium",
  "m5.large",
  "m5a.large",
  "m5.xlarge",
  "m5a.xlarge",
  "m5.2xlarge",
  "m5a.2xlarge",
  "m6g.large",
  "m6g.xlarge",
  "m6g.2xlarge",
]
karpenter_vpc_az = [
  "ap-southeast-1a",
  "ap-southeast-1b",
  "ap-southeast-1c",
]
karpenter_ec2_arch                  = ["amd64"]
karpenter_ec2_capacity_type         = ["spot", "on-demand"]
karpenter_ttl_seconds_after_empty   = 300
karpenter_ttl_seconds_until_expired = 604800            