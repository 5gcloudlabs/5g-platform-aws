# AWS EKS Multus CNI Helm Chart

Part of **5G Platform AWS** cluster bootstrap. Required for multi-interface telecom pods (N2/N3/N4/N6).

## Purpose

This Helm chart is derived from the official AWS Multus CNI manifest (https://github.com/aws/amazon-vpc-cni-k8s/blob/master/config/multus/v3.7.2-eksbuild.1/aws-k8s-multus.yaml).  
It deploys the Multus DaemonSet on Amazon EKS.

---

## Overview

Multus CNI enables Kubernetes pods to connect to multiple networks, adding secondary interfaces alongside the default cluster network.

Key features include:

- Supports multiple network attachments per pod, providing flexibility for advanced networking scenarios such as multi-homed pods.
- Integrates with other CNI plugins, such as AWS VPC CNI, IPVLAN, and Host-Device.

---

## Deployment

- This chart is deployed and managed via Argo CD.
- The corresponding Argo CD Application manifest is defined in
  [`multus-app.yml`](../../argocd/required-apps/multus-app.yml).
- The application manifest is included in the "required-apps" set and is deployed automatically by Argo CD post EKS cluster creation.
- The pod runs the container image `602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/multus-cni:v3.7.2-eksbuild.1`

---

## References

- https://github.com/k8snetworkplumbingwg/multus-cni
- https://github.com/aws/amazon-vpc-cni-k8s/blob/master/config/multus/v3.7.2-eksbuild.1/aws-k8s-multus.yaml

---

## License & Attribution

This Helm chart was created by restructuring and packaging content from the  
[AWS Multus CNI manifest](https://github.com/aws/amazon-vpc-cni-k8s/blob/master/config/multus/v3.7.2-eksbuild.1/aws-k8s-multus.yaml).  
The original manifest is licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).  

This chart was created and is maintained by © 5G Cloud Labs.

