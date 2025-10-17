# UERANSIM Argo CD Application

## Purpose
This Argo CD `Application` manifest defines the deployment of the [UERANSIM Helm chart](../../charts/ueransim) on Amazon EKS.  
It automates the deployment of UERANSIM components used for 5G RAN and UE simulation within the AWS 5G Cloud Labs environment.

---

## Overview
The manifest registers a UERANSIM deployment as an Argo CD `Application`.  
Key details include:

- **Source** – Pulls the Helm chart from the `charts/ueransim` path of the `trims` branch in the Git repository.  
- **Release** – Deploys under the release name `aws-5gcloudlabs`.  
- **Namespace** – Installs all UERANSIM components into the `ueransim` namespace.  
- **Sync Policy** – Uses automated synchronization with pruning and self-healing enabled to maintain workload consistency.  

The deployment includes simulated **gNB (gNodeB)** and **UE (User Equipment)** components, which connect to the deployed [free5GC](https://free5gc.org/) 5G Core network.  
Key parameters such as **PLMN**, **gNB ID**, and **subscriber profiles** are automatically aligned with the 5G Core configuration through provisioning workflows triggered by the Console UI.

---

## Deployment Flow
- This `Application` manifest is one of the **required apps** deployed by Argo CD after cluster provisioning.  
- When applied, Argo CD installs the UERANSIM components from the predefined Helm chart.  
- The Console UI triggers UERANSIM deployment and manages runtime operations such as gNB registration and UE attachment to the 5G Core.  

This provides a repeatable and consistent deployment process for simulating RAN and UE behavior on Amazon EKS.

---

## References
- [UERANSIM Helm chart](../../charts/ueransim) – Underlying Helm chart deployed by this manifest.  
- [UERANSIM](https://github.com/aligungr/UERANSIM) – Open-source 5G UE and RAN simulator.  
- [Argo CD Applications](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/) – Official documentation for declarative app management.  

---

## License & Attribution
This manifest is maintained by © 2025 5g-cloud-labs (a project by CNAD LTD.).  
The UERANSIM chart is adapted from [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm), licensed under Apache 2.0.  
