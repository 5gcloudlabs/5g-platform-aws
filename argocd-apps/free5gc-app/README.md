# free5GC Argo CD Application

## Purpose
This Argo CD `Application` manifest defines the deployment of the [free5GC Helm chart](../../charts/free5gc) on Amazon EKS.  
It provides a declarative way to deploy and manage the **free5GC 5G Core Network** through Argo CD, using the Git repository as the source of truth for configuration.

---

## Overview
The manifest registers a free5GC deployment as an Argo CD `Application`.  
Key details include:

- **Source** – Pulls the Helm chart from the `charts/free5gc` path in the Git repository.  
- **Release** – Deploys under the release name `aws-5gcloudlabs`.  
- **Namespace** – Installs all free5GC components into the `free5gc` namespace.  
- **Sync Policy** – The repository provides a stable reference state; Argo CD syncs automatically, but deployments are typically short-lived and based on the latest commit.

The deployment includes key 5G Core network functions such as **AMF**, **AUSF**, **NRF**, **NSSF**, **UDM**, **UDR**, **SMF**, and **UPF**.  
Configuration parameters like **MCC (Mobile Country Code)** and **MNC (Mobile Network Code)** are templated as `$mcc` and `$mnc`, and can be patched by higher-level workflows (e.g., the Console UI or automation scripts) prior to deployment.

---

## Deployment Flow
- This `Application` manifest is applied via Argo CD after cluster provisioning.  
- When triggered, Argo CD deploys the free5GC Helm chart into the target namespace using the declared chart path and values.  
- The repository serves as the centralized source for manifests, with Argo CD automatically synchronizing the latest stable state for short-lived deployments.

This approach provides a **reproducible and consistent** deployment process for the free5GC 5G Core on Amazon EKS without relying on continuous GitOps reconciliation.

---

## References
- [free5GC Helm chart](../../charts/free5gc) – Underlying Helm chart deployed by this manifest.  
- [free5GC](https://free5gc.org/) – Open-source 5G Core implementation.  
- [Argo CD Applications](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/) – Official documentation for declarative app management.  

---

## License & Attribution
This manifest is maintained by © 2025 5g-cloud-labs (a project by CNAD LTD.).  
The free5GC chart is adapted from [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm), licensed under Apache 2.0.
