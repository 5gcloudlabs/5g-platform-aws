# 5G Platform AWS

**AWS-based telecom laboratory platform for experimenting with AI and automation use cases.**

---

## Overview

5G Platform AWS is the reference implementation of the 5G Cloud Labs project.

The repository provides an automated deployment of a Kubernetes-based telecom environment on AWS and serves as a foundation for experimenting with automation and AI-assisted operational workflows.

The platform combines Infrastructure as Code, GitOps practices, and open-source telecom software to create a reproducible environment suitable for testing ideas that would otherwise require access to dedicated telecom lab infrastructure.

---

## Purpose

The primary purpose of this project is to provide a practical telecom laboratory environment.

While the automated deployment of a 5G environment on AWS is an important capability, it is not the end goal of the project.

The deployed environment serves as a foundation for exploring:

- Automation workflows
- AI-assisted operations
- Deployment tooling
- Network validation
- Observability practices
- Operational runbooks
- Subscriber lifecycle automation

---

## Background

The project began as an effort to automate the deployment of a complete 5G environment on AWS.

Over time, the scope expanded beyond deployment automation to focus on providing a reusable environment for experimentation and learning.

Today, the platform acts as a laboratory where automation and AI use cases can be developed and evaluated against realistic telecom workloads.

---

## Current Implementation

### Infrastructure layer

Provisioned with OpenTofu (`infrastructure/`):

- VPC (primary and secondary CIDR for Multus networking)
- Amazon EKS (dedicated control-plane and user-plane node groups)
- Secondary ENIs, subnets, and security groups for 3GPP interfaces (N2, N3, N4, N6)
- EFS, ACM, IAM / IRSA, SSM
- Argo CD installation and cluster-bootstrap Application registration

### Kubernetes layer

Synced by Argo CD after OpenTofu apply (`cluster-bootstrap/`):

- Argo CD (GitOps, envsubst CMP plugin)
- Argo Workflows
- Istio, ingress, cert-manager, external-dns
- AWS Load Balancer Controller, EFS CSI driver
- Multus, Whereabouts
- Prometheus, Grafana, Loki

Telecom workloads are **not** installed at bootstrap. They are deployed on demand through the Telco Deployment Assistant.

### Telecom layer

Deployed on demand via the assistant or Argo Workflows (`5g/`):

- free5GC (5G Core network functions)
- Subscriber provisioning Job
- UERANSIM (gNB and UE simulation)

### User interface

- Telco Deployment Assistant (`ai-agent`) at `https://console.<your-domain>`
- Amazon Bedrock for intent parsing and guided operator interaction
- Status checks and connectivity validation from the same console

---

## Current Experiment

### Telco Deployment Assistant

The first AI and automation experiment built on top of this platform is the Telco Deployment Assistant.

The assistant simplifies the creation of a telecom environment by automating a number of operational tasks, including deployment workflows, subscriber provisioning, and simulation setup.

Technically, it is implemented as the `ai-agent` service: a web console backed by Amazon Bedrock. The user describes the desired outcome in natural language; Bedrock selects a single-step Argo CD application or a multi-step Argo Workflow, collects parameters such as MCC, MNC, and subscriber count, fetches manifests from this repository, and applies them to the cluster.

The objective is to explore how AI-assisted tooling can support telecom operations and reduce operational complexity.

---

## Architecture

Two phases: **provision** the lab once with OpenTofu, then **operate** it through the Telco Deployment Assistant.

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
              │  EKS cluster + Argo CD install        │  → Argo Workflows / Argo CD apps
              │  cluster-bootstrap sync               │
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
├── infrastructure/     OpenTofu — AWS infrastructure, EKS, Argo CD bootstrap
├── cluster-bootstrap/  Argo CD apps — platform add-ons and ai-agent
├── 5g/                 Helm charts, ArgoCD apps, workflows — telecom payloads
└── docs/               Installation guides and architecture diagrams
```

---

## Areas of Interest

Future work may include experiments related to:

- AI-assisted deployment workflows
- Troubleshooting assistance
- Configuration generation
- Operational automation
- Network validation
- Observability workflows
- Subscriber lifecycle management
- Multi-cloud deployments

The direction of the project will be guided by practical experimentation and learning.

---

## Getting Started

Documentation and deployment guides are available in the [`docs/`](./docs/) directory.

Typical workflow:

1. Provision AWS infrastructure with OpenTofu (`infrastructure/`)
2. Wait for cluster-bootstrap to sync in Argo CD (platform add-ons, including the Telco Deployment Assistant)
3. Open `https://console.<your-domain>` and deploy the 5G environment via the assistant — for example: *"Deploy the full 5G solution with MCC 602, MNC 02, and 10 subscribers"*
4. Validate connectivity and explore automation and AI-assisted workflows

Detailed steps: [Installation instructions](./docs/installation-instructions/00%20infrastructure.md) · [Telco Deployment Assistant](./docs/installation-instructions/01%20ai-agent-console.md)

---

## Contributing

Contributions are welcome.

Please open an issue or submit a pull request to discuss improvements, bug fixes, or new ideas.

---

## License

Apache License 2.0

---

## Maintainer

5G Cloud Labs

info@5gcloudlabs.ai
