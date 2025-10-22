# Required Apps Argo CD Application

## Purpose
This Argo CD `Application` manifest deploys a collection of **supporting applications** required for running the main workloads (**free5GC** and **UERANSIM**) on Amazon EKS.  
These applications provide networking, observability and user interface for the end-to-end 5G deployment workflow.

---

## Overview
The manifest defines an app of apps in Argo CD named required-apps, which coordinates the deployment of multiple supporting applications.

- **multus-app** and **whereabouts-app** – Extend Kubernetes networking with multi-interface and IPAM capabilities.
- **Executor-app** and **Console-app** – Provide a UI interface for deployment automation workflows.
- **curl-app** – Utility pod enables subscriber provisioning. 
- **kube-prometheus-stack-crd** and **kube-prometheus-stack-app** – Provide monitoring, metrics, and alerting for cluster resources.  
- **loki-stack-app** – Enables centralized log aggregation and querying.  

These applications are deployed under the `argocd` namespace using Argo CD’s **Application of Applications** pattern, allowing unified management of all the required apps as a single logical entity.

---

## Deployment Flow
The `required-apps` manifest is triggered automatically at the **end of infrastructure provisioning**, defined as a `kubectl_manifest` resource in the OpenTofu configuration.

---

## References

Argo CD Applications
 – Official documentation for declarative app management.

Helm Charts Repository
 – Underlying Helm charts used by the sub-applications.

---

## License & Attribution

This manifest is maintained by © 2025 5g-cloud-labs (a project by CNAD LTD.).
All referenced Helm charts and manifests are open source under their respective licenses.
