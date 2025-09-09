# free5GC Argo CD Application

## Purpose
This Argo CD `Application` manifest defines the deployment of the [free5GC Helm chart](../../charts/free5gc) on Amazon EKS.  
It enables GitOps-based management of the full free5GC 5G Core network, ensuring that configuration and lifecycle are declaratively controlled from source.

---

## Overview
The manifest registers a free5GC deployment as an Argo CD `Application`.  
Key details include:

- **Source** – Pulls the Helm chart from the `charts/free5gc` path of the `trims` branch in the Git repository.  
- **Release** – Deploys under the release name `aws-5gcloudlabs`.  
- **Namespace** – Installs all free5GC components into the `free5gc` namespace.  
- **Sync Policy** – Uses automated synchronization with pruning and self-healing enabled to keep workloads in the desired state.  

Configuration is customized for 5G Core network functions (AMF, AUSF, NRF, NSSF, SMF), with key parameters such as **MCC (Mobile Country Code)** and **MNC (Mobile Network Code)** templated as `$mcc` and `$mnc`.  
These values are dynamically patched by higher-level workflows (e.g., the Console UI or CLI) to align the deployment with the target operator profile.

---

## Deployment Flow
- This `Application` manifest is part of the **required apps** automatically synchronized by Argo CD.  
- When applied, Argo CD continuously monitors the Git repository and ensures the free5GC Helm release matches the declared state.  
- Updates to MCC/MNC values are injected into the manifest, and Argo CD reconciles the deployment accordingly.  

This approach provides a fully automated, GitOps-driven deployment pipeline for the free5GC 5G Core on Amazon EKS.

---

## References
- [free5GC Helm chart](../../charts/free5gc) – Underlying Helm chart deployed by this manifest.  
- [free5GC](https://free5gc.org/) – Open-source 5G Core implementation.  
- [Argo CD Applications](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/) – Official documentation for declarative app management.  

---

## License & Attribution
This manifest is maintained by © 2025 5g-cloud-labs (a project by CNAD LTD.).  
The free5GC chart is adapted from [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm), licensed under Apache 2.0.  
