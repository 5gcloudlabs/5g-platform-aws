# UERANSIM Argo CD Application

## Purpose
This Argo CD `Application` manifest defines the deployment of the [UERANSIM Helm chart](../../charts/ueransim) on Amazon EKS.  
It provides a declarative way to deploy and manage **UERANSIM** — the open-source 5G RAN and UE simulator — through Argo CD, using the Git repository as the configuration source.

---

## Overview
The manifest registers a UERANSIM deployment as an Argo CD `Application`.  
Key details include:

- **Source** – Pulls the Helm chart from the `charts/ueransim` path in the Git repository.  
- **Release** – Deploys under the release name `aws-5gcloudlabs`.  
- **Namespace** – Installs UERANSIM components into the `ueransim` namespace.  
- **Sync Policy** – Configured for on-demand synchronization rather than continuous GitOps-based reconciliation.  

UERANSIM emulates the behavior of **gNBs (Next Generation Node Bs)** and **UEs (User Equipment)**, enabling realistic end-to-end 5G testing alongside the [free5GC](https://free5gc.org/) core network.  
Deployment parameters such as network PLMN identifiers (**MCC** and **MNC**) can be dynamically patched by higher-level automation workflows (e.g., the Console UI or backend services) before applying this manifest.

---

## Deployment Flow
- This `Application` manifest is applied via Argo CD after the EKS cluster and supporting infrastructure are provisioned.  
- When executed, Argo CD deploys the UERANSIM Helm chart using the defined repository path and configuration values.  
- The repository serves as the single source of truth, but there is **no continuous Git-based synchronization** — updates are applied manually or through controlled automation workflows.  

This ensures a **stable and reproducible** UERANSIM deployment environment that integrates seamlessly with the free5GC 5G Core on Amazon EKS.

---

## References
- [UERANSIM Helm chart](../../charts/ueransim) – Underlying Helm chart deployed by this manifest.  
- [UERANSIM](https://github.com/aligungr/UERANSIM) – Open-source 5G RAN and UE simulator.  
- [Argo CD Applications](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/) – Official documentation for declarative app management.  

---

## License & Attribution
This manifest is maintained by © 2025 5g-cloud-labs (a project by CNAD LTD.).  
The UERANSIM chart is adapted from [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm), licensed under Apache 2.0.
