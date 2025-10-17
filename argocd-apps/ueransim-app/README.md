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
- **Sync Policy** – Configured to support automated synchronization with pruning/self-healing when Argo CD reconciliation is used.

The deployment includes simulated **gNB (gNodeB)** and **UE (User Equipment)** components, which connect to the deployed [free5GC](https://free5gc.org/) 5G Core network.  
Runtime parameters such as **PLMN**, **gNB ID**, and **subscriber profiles** are aligned with the 5G Core configuration via provisioning workflows triggered by the Console UI.

---

## Deployment Flow
- The Argo CD `Application` manifest is present in the repository as the canonical declaration of the UERANSIM deployment.  
- When applied (manually or as part of an operator-driven process), Argo CD installs the UERANSIM components from the predefined Helm chart.  
- The Console UI triggers UERANSIM actions at runtime (for example, gNB registration and UE attachment) to exercise and validate the 5G Core.

This provides a repeatable, declarative deployment that operators can apply to provision RAN/UE simulation components on Amazon EKS.

---

## References
- [UERANSIM Helm chart](../../charts/ueransim) – Underlying Helm chart deployed by this manifest.  
- [UERANSIM](https://github.com/aligungr/UERANSIM) – Open-source 5G UE and RAN simulator.  
- [Argo CD Applications](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/) – Docs for Argo CD application manifests.  

---

## License & Attribution
This manifest is maintained by © 2025 5g-cloud-labs (a project by CNAD LTD.).  
The UERANSIM chart is adapted from [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm), licensed under Apache 2.0.
