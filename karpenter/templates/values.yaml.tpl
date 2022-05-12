# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${ karpenter_iam_role }

nodeSelector:
  eks.amazonaws.com/nodegroup: ${ karpenter_node_group }
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: karpenter
            operator: In
            values:
            - controller
        topologyKey: topology.kubernetes.io/zone

replicas: 3
clusterName: ${ cluster_name }
clusterEndpoint: ${ cluster_endpoint }