# Required Apps Argo CD Application

## Purpose
This Argo CD `Application` manifest deploys a collection of **supporting add-ons** required for running the main workloads (**free5GC** and **UERANSIM**) on Amazon EKS.  
These add-ons provide observability, networking, and control-plane functionality essential for the end-to-end 5G deployment workflow.

---

## Overview
The manifest registers a **meta-application** in Argo CD named `required-apps`, which manages the deployment of several supporting components through sub-applications:

- **console-app** – Web-based deployment Console UI.  
- **curl-app** – Utility pod for HTTP testing and API validation.  
- **executor-app** – Executes backend provisioning and deployment scripts.  
- **kube-prometheus-stack-crd** and **kube-prometheus-stack-app** – Provide monitoring, metrics, and alerting for cluster resources.  
- **loki-stack-app** – Enables centralized log aggregation and querying.  
- **multus-app** and **whereabouts-app** – Extend Kubernetes networking with multi-interface and IPAM capabilities.

These applications are deployed under the `argocd` namespace using Argo CD’s **Application of Applications** pattern, allowing unified management of all add-ons as a single logical entity.

---

## Deployment Flow
The `required-apps` manifest is triggered automatically at the **end of infrastructure provisioning**, defined as a `kubectl_manifest` resource in the OpenTofu configuration.

