# 5G Cloud Labs

**An open-source cloud-based telecom laboratory for experimenting with AI and automation use cases.**

---

## Overview

5G Cloud Labs is an open-source initiative focused on creating practical telecom laboratory environments for experimenting with automation and AI-assisted operational workflows.

The project combines Infrastructure as Code, Kubernetes, GitOps practices, and open-source telecom software to create reproducible environments suitable for experimentation, learning, and prototyping.

The goal is not simply to deploy telecom workloads, but to provide a foundation where automation and AI ideas can be developed, tested, and evaluated against realistic network environments.

---

## Why 5G Cloud Labs?

5G Cloud Labs provides a reproducible telecom environment that can be deployed on demand and used to evaluate automation and AI use cases against realistic network workloads.

The platform is intended to reduce the effort required to create a functional telecom test environment, allowing engineers to focus on experimentation rather than infrastructure setup.

Current capabilities enable users to:

- Deploy a complete telecom laboratory environment in minutes
- Evaluate automation workflows against realistic network functions
- Test AI-assisted operational tooling
- Validate deployment procedures and runbooks
- Experiment with subscriber provisioning workflows
- Simulate radio access and user equipment behaviour
- Recreate environments consistently for testing and learning

The objective is to provide a practical foundation for experimentation, iteration, and learning.

---

## The Laboratory Today

The project currently provides an AWS-based telecom laboratory environment that can be deployed on demand and used for experimentation.

Deployment follows two phases: **provision** the cloud and Kubernetes platform with OpenTofu, then **operate** the telecom environment through guided workflows.

The environment combines:

**Infrastructure and platform**
- OpenTofu — AWS infrastructure (VPC, EKS, persistent storage, IAM, TLS)
- Multi-interface networking — Multus CNI and dedicated ENIs for 3GPP traffic separation (N2, N3, N4, N6)
- Argo CD — GitOps bootstrap of cluster platform services
- Istio, cert-manager, and external DNS — ingress, service mesh, and automated TLS
- Prometheus, Grafana, and Loki — metrics, dashboards, and log aggregation
- Argo Workflows — multi-step telecom deployment orchestration

**Telecom workloads** *(deployed on demand, not at install time)*
- free5GC — 5G Core network functions (AMF, SMF, UPF, UDM, UDR, and others)
- Subscriber provisioning — automated test subscriber creation
- UERANSIM — gNodeB and UE simulation for registration and data-plane testing

**Experiments**
- [Telco Deployment Assistant](https://github.com/5g-cloud-labs/telco-deployment-assistant) — AI-assisted deployment, parameter collection, and operational validation (Amazon Bedrock)

The first experiment built on this environment is the **Telco Deployment Assistant**, which explores how AI-assisted tooling can simplify deploying and operating a telecom laboratory without manual CLI steps or fixed deployment scripts.

This is an ongoing project and an open invitation to experiment, learn, and contribute. Future work may expand existing capabilities, introduce new automation workflows, or explore entirely new AI use cases.

AWS currently serves as the primary laboratory environment. Additional cloud platforms may be introduced over time where they help broaden experimentation and learning opportunities.

---

## Repositories

### Platform Environments

| Repository | Description |
|------------|-------------|
| [`5g-platform-aws`](https://github.com/5g-cloud-labs/5g-platform-aws) | AWS laboratory — OpenTofu infrastructure, EKS GitOps bootstrap, free5GC, UERANSIM, and on-demand telecom deployment |
| `5g-platform-gcp` | GCP laboratory *(future)* |

### Experiments

| Repository | Description |
|------------|-------------|
| [`telco-deployment-assistant`](https://github.com/5g-cloud-labs/telco-deployment-assistant) | AI-assisted deployment and operational workflows — natural-language intent, Bedrock, and Argo orchestration |

---

## Project Philosophy

5G Cloud Labs is intentionally experimental.

The project does not aim to prescribe how telecom automation or AI-assisted operations should be implemented.

Instead, it provides an environment where ideas can be explored, tested, and evaluated against realistic telecom workloads.

Contributions, alternative approaches, and new experiments are encouraged.

---

## Getting Started

If you're new to the project, start with:

➡ **[5g-platform-aws](https://github.com/5g-cloud-labs/5g-platform-aws)**

This repository contains the AWS laboratory environment: infrastructure provisioning, cluster bootstrap, telecom payloads, and documentation for the full deploy-and-operate workflow.

---

## Contributing

Contributions, ideas, discussions, and experiments are welcome.

Whether your interests are in:

- Telecommunications
- Cloud Infrastructure
- Kubernetes
- Infrastructure as Code
- GitOps
- Automation
- Artificial Intelligence

there is room to experiment, learn, and contribute.

---

## Links

🌐 Website: https://5gcloudlabs.ai

📧 Contact: info@5gcloudlabs.ai
