# AWS EKS Multus CNI Helm Chart

## Purpose

This Helm chart, derived from the official AWS Multus CNI manifest (https://github.com/aws/amazon-vpc-cni-k8s/blob/master/config/multus/v3.7.2-eksbuild.1/aws-k8s-multus.yaml), deploys the Multus DaemonSet on Amazon EKS.

---

## Overview

Multus CNI is a Container Network Interface plugin that enables Kubernetes pods to attach to multiple networks simultaneously.  
It allows pods to use secondary interfaces in addition to the primary cluster network.

Key features include:

- Supports multiple network attachments per pod.
- Integrates with other CNI plugins, such as AWS VPC CNI, IPVLAN, and Host-Device.
- Provides flexibility for complex networking scenarios, including multi-homed pods.

---

## Deployment

---

## References


---

## License & Attribution

- **Original license:** Apache License 2.0 (see [LICENSE](./LICENSE))

