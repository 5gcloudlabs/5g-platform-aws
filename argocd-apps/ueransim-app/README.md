# UERANSIM Argo CD Application

## Purpose
This Argo CD `Application` manifest defines the deployment of the [UERANSIM Helm chart](../../charts/ueransim) on Amazon EKS.  
It enables GitOps-based management of the UERANSIM components used for 5G RAN and UE simulation, ensuring declarative configuration and lifecycle control from source.

---

## Overview
The manifest registers a UERANSIM deployment as an Argo CD `Application`.  
Key details include:

- **Source** – Pulls the Helm chart from the `charts/ueransim` path of the `trims` branch in the Git repository.  
- **Release** – Deploys under the release name `aws-5gcloudlabs`.  
- **Namespace** – Installs all UERANSIM components into the `ueransim` namespace.  
- **Sync Policy** – Uses automated synchronization with pruning and self-healing enabled to keep workloads in the desired state.  

Configuration includes the simulated **gNB (gNodeB)** and **UE (User Equipment)** instances, which connect to the deployed [free5GC](https://free5gc.org/) 5G Core network.  
Key runtime parameters such as **PLMN**, **gNB ID**, and **subscriber profiles** are automatically aligned with the 5G Core configuration through upstream provisioning workflows triggered by the Console UI.

---

## Deployment Flow
- This `Application` manifest is part of the **required apps** automatically synchronized by Argo CD.  
- When applied, Argo CD continuously monitors the Git repository and ensures the UERANSIM Helm release matches the declared state.  
- Once the 5G Core is ready, the Console UI triggers UERANSIM deployment to simulate access and user equipment connections to the network.  

This GitOps-driven model provides reproducible, automated simulation of RAN and UE components integrated with the 5G Core on Amazon EKS.

---

## References
- [UERANSIM Helm chart](../../charts/ueransim) – Underlying Helm chart deployed by this manifest.  
- [UERANSIM](https://github.com/aligungr/UERANSIM) – Open-source 5G UE and RAN simulator.  
- [Argo CD Applications](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/) – Official documentation for declarative app management.  

---

## License & Attribution
This manifest is maintained by © 2025 5g-cloud-labs (a project by CNAD LTD.).  
The UERANSIM chart is adapted from [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm), licensed under Apache 2.0.  
