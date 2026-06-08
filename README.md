# 5G Platform AWS

**AWS-based telecom laboratory environment.**

Part of [5G Cloud Labs](https://5gcloudlabs.ai) — an open-source initiative for practical telecom laboratory environments.

---

## Overview

5G Platform AWS is the first laboratory environment developed as part of the 5G Cloud Labs project.

The repository provides an automated deployment of a Kubernetes-based telecom environment on AWS and serves as a foundation for experimenting with automation and AI-assisted operational workflows.

It combines Infrastructure as Code, Kubernetes, GitOps practices, and open-source telecom software to create a reproducible environment that can be deployed on demand and used for learning, testing, and experimentation.

Deployment follows two phases:

1. **Provision** — OpenTofu creates AWS infrastructure, installs Argo CD, and bootstraps the Kubernetes platform
2. **Operate** — the [Telco Deployment Assistant](https://github.com/5g-cloud-labs/telco-deployment-assistant) deploys and validates telecom workloads via natural-language chat at `https://console.<your-domain>`

---

## Purpose

While the automated deployment of a Kubernetes-based 5G environment on AWS is a key capability of this project, the environment itself is intended to support a broader goal: providing a practical laboratory for experimenting with automation and AI use cases in telecom networks.

The platform is designed to reduce the effort required to create a functional telecom environment, allowing engineers to focus on experimentation rather than infrastructure setup.

The project aims to provide a realistic environment where ideas can be explored, tested, validated, and improved using real telecom workloads.

---

## What Can Be Done With This Environment?

The laboratory can be used to:

- Deploy a complete telecom laboratory environment in minutes
- Evaluate automation workflows against realistic network functions
- Experiment with AI-assisted operational tooling
- Validate deployment procedures and runbooks
- Test subscriber provisioning workflows
- Simulate radio access and user equipment behaviour
- Explore Kubernetes-based telecom deployments
- Recreate environments consistently for testing and learning

The environment is intentionally flexible and is expected to evolve as new experiments and ideas emerge.

---

## The Laboratory Today

The current environment combines cloud infrastructure, Kubernetes, GitOps practices, and telecom workloads into a reproducible laboratory that can be deployed on demand.

### Infrastructure and platform

**Infrastructure provisioning** (`infrastructure/`)

- OpenTofu — AWS infrastructure (VPC, EKS, persistent storage, IAM, TLS)
- Argo CD — GitOps bootstrap of cluster platform services

**Platform services** (`cluster-bootstrap/`)

- Multi-interface networking — Multus CNI and Whereabouts IPAM for 3GPP traffic separation (N2, N3, N4, N6)
- Istio, cert-manager, and external DNS — ingress, service mesh, and automated TLS
- Prometheus, Grafana, and Loki — metrics, dashboards, and log aggregation
- Argo Workflows — multi-step telecom deployment orchestration
- Telco Deployment Assistant (`ai-agent`) — deployed during cluster bootstrap as the operator console

### Telecom workloads

**Telecom components** (`5g/`) — *deployed on demand, not at install time*

- free5GC — 5G Core network functions (AMF, SMF, UPF, UDM, UDR, and others)
- Subscriber provisioning — automated test subscriber creation
- UERANSIM — gNodeB and UE simulation for registration and data-plane testing

### Experiments

- [Telco Deployment Assistant](https://github.com/5g-cloud-labs/telco-deployment-assistant) — AI-assisted deployment, parameter collection, and operational validation (Amazon Bedrock)

---

## Current Experiment

### Telco Deployment Assistant

The first experiment built on top of this laboratory environment is the Telco Deployment Assistant.

The assistant explores how AI-assisted tooling can simplify the deployment and operation of telecom platforms by automating operational tasks that would traditionally require manual execution.

Current capabilities include:

- Guided deployment workflows via natural-language chat
- Platform configuration assistance and parameter collection
- Subscriber provisioning automation
- RAN and UE simulation workflows (free5GC, UERANSIM)
- Operational validation through Argo Workflows and Argo CD applications

The assistant is deployed from this repository as the `ai-agent` service during cluster bootstrap. Its source code lives in the separate [`telco-deployment-assistant`](https://github.com/5g-cloud-labs/telco-deployment-assistant) repository.

The objective is to better understand where AI-assisted tooling can provide practical value in telecom operations.

---

## Architecture

```text
                         ┌─────────────────────┐
                         │        User         │
                         └──────────┬──────────┘
                                    │
              ┌─────────────────────┴─────────────────────┐
              │                                           │
              ▼                                           ▼
   ┌──────────────────────┐              ┌──────────────────────────────┐
   │  Phase 1 — Provision │              │  Phase 2 — Operate           │
   │  OpenTofu (local)    │              │  Telco Deployment Assistant  │
   │                      │              │  (ai-agent + Amazon Bedrock) │
   └──────────┬───────────┘              └──────────────┬───────────────┘
              │                                         │
              │  AWS infrastructure                     │  chat at console.<domain>
              │  EKS cluster + Argo CD install          │  → Argo Workflows / Argo CD apps
              │  cluster-bootstrap sync                 │
              │                                         ▼
              │                          ┌──────────────────────────────┐
              └─────────────────────────►│  Telecom workloads (on EKS)  │
                                         │  free5GC · sub-prov · UERANSIM│
                                         └──────────────────────────────┘

   ┌──────────────────────────────────────────────────────────────────────┐
   │                              AWS                                      │
   │  VPC · ENIs · EFS · ACM · IAM                                         │
   │  Amazon EKS                                                           │
   │    └── Platform add-ons (Argo CD, Istio, Multus, observability, …)   │
   └──────────────────────────────────────────────────────────────────────┘
```

---

## Repository Structure

```text
.
├── infrastructure/       OpenTofu — AWS infrastructure, EKS, Argo CD bootstrap
├── cluster-bootstrap/    Argo CD apps — platform add-ons, observability, ai-agent
├── 5g/                     Helm charts, Argo CD apps, workflows — telecom payloads
└── docs/                   Installation guides and architecture diagrams
```

---

## Deployment Workflow

A typical workflow consists of:

1. **Provision** — configure OpenTofu variables and apply (`infrastructure/`) to create AWS resources, EKS, and Argo CD
2. **Bootstrap** — wait for `cluster-bootstrap` applications to sync in Argo CD (Istio, Multus, Whereabouts, observability, Argo Workflows, ai-agent)
3. **Operate** — open `https://console.<your-domain>` and use the Telco Deployment Assistant to deploy telecom workloads — for example:

   *"Deploy the full 5G solution with MCC 602, MNC 02, and 10 subscribers"*

4. **Validate** — confirm subscriber registration, data-plane connectivity, and UERANSIM simulation
5. **Experiment** — explore automation workflows, runbooks, and AI-assisted operational tasks
6. **Teardown** — follow [terminate.md](docs/installation-instructions/terminate.md) when finished

---

## Relationship to 5G Cloud Labs

This repository represents the AWS-based laboratory environment within the broader 5G Cloud Labs project.

5G Cloud Labs is an open-source cloud-based telecom laboratory for experimenting with AI and automation use cases.

The long-term objective is to provide practical telecom environments where new ideas can be explored, tested, and evaluated against realistic network workloads.

AWS currently serves as the primary laboratory environment. Additional cloud platforms may be introduced over time where they help broaden experimentation and learning opportunities.

---

## Getting Started

### Prerequisites

- AWS account, Cloudflare domain + API token, Amazon Bedrock model access
- AWS CLI, OpenTofu, kubectl

### Quick start

```bash
git clone https://github.com/5g-cloud-labs/5g-platform-aws.git
cd 5g-platform-aws/infrastructure

# Configure vars.auto.tfvars (domain, Cloudflare, S3 backend, Bedrock settings)
tofu init
tofu apply
```

After cluster bootstrap syncs in Argo CD, open `https://console.<your-domain>` and deploy telecom workloads via the Telco Deployment Assistant.

### Documentation

| Guide | Description |
|-------|-------------|
| [docs/](docs/) | Documentation index |
| [Installation — infrastructure](docs/installation-instructions/00%20infrastructure.md) | OpenTofu provisioning and bootstrap validation |
| [Telco Deployment Assistant](docs/installation-instructions/01%20ai-agent-console.md) | Deploy and validate telecom workloads |
| [Architecture diagrams](docs/arch/) | VPC, EKS, CNI, and ingress design |
| [Terminate environment](docs/installation-instructions/terminate.md) | Tear down AWS resources |

If you are new to the project, start with the installation and deployment guides before exploring the available experiments and workflows.

---

## Related repositories

| Repository | Description |
|------------|-------------|
| [`telco-deployment-assistant`](https://github.com/5g-cloud-labs/telco-deployment-assistant) | AI assistant source — Bedrock intent, workflow selection, and operator chat |
| `5g-platform-gcp` | GCP laboratory *(future)* |

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

Please open an issue or submit a pull request to discuss improvements, fixes, or new ideas.

---

## License

Apache License 2.0 — see [LICENSE](LICENSE).

---

## Maintainer

**5G Cloud Labs**

🌐 Website: https://5gcloudlabs.ai

📧 Contact: info@5gcloudlabs.ai
