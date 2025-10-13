# Infrastructure

This directory defines and provisions all the underlying **AWS** and **Kubernetes** infrastructure components required for the **AWS 5G Cloud Labs** environment.  
All infrastructure is deployed using **[OpenTofu](https://opentofu.org/)** — an open-source Infrastructure as Code (IaC) tool fully compatible with Terraform syntax.

---

## 🏗️ Architecture Overview

```mermaid
graph TD

A[OpenTofu IaC] --> B[AWS Resources]
B --> C[EKS Cluster]
C --> D[Kubernetes Add-ons]
D --> E[Argo CD (GitOps)]
E --> F[5G Workloads (Free5GC & UERANSIM)]

B -->|Networking, Storage, IAM| C
C -->|Helm Charts| D
D -->|Manages Deployments| F
