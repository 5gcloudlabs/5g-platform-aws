# Helm Charts

This directory contains the locally maintained Helm charts used to deploy the main and supporting components of the **AWS 5G Cloud Labs** environment on Amazon EKS.

## Charts

| Chart | Description |
|--------|-------------|
| **console** | Deploys the Console UI for managing 5G network deployment and provisioning workflows. |
| **curl** | Deploys a lightweight test utility pod for validating network connectivity. |
| **executor** | Deploys the Executor component responsible for running automation and provisioning scripts. |
| **free5gc** | Deploys the complete free5GC 5G Core Network. |
| **multus** | Deploys the Multus CNI plugin for multi-interface pod networking. |
| **ueransim** | Deploys the UERANSIM components to simulate gNB and UE traffic. |

## Notes

These charts are referenced by the corresponding Argo CD `Application` manifests to enable automated and declarative deployment.

