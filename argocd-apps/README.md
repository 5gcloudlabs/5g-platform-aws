# Argo CD Applications

This directory contains Argo CD `Application` manifests used to deploy components of the **AWS 5G Cloud Labs** environment on Amazon EKS.

## Applications

| Application | Description |
|--------------|-------------|
| **required-apps** | Defines an *App of Apps* that deploys supporting add-ons such as Multus, Whereabouts, Prometheus, Loki, Console, Executor, and curl utilities. |
| **free5gc-app** | Deploys the full **free5GC 5G Core Network** using the corresponding Helm chart. |
| **ueransim-app** | Deploys **UERANSIM**, simulating gNB and UE behavior for testing and validation. |

## Notes

All applications are managed by Argo CD for automated synchronization and lifecycle management once the cluster is provisioned.
