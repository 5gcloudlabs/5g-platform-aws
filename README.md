# 5G Platform AWS

**AWS-based telecom laboratory for experimenting with AI and automation use cases.**

Part of [5G Cloud Labs](https://5gcloudlabs.ai) — an open-source initiative for practical telecom laboratory environments.

---

## Overview

This repository is the reference AWS implementation of the 5G Cloud Labs platform. It provides a reproducible Kubernetes-based telecom environment on Amazon EKS — not only to deploy 5G workloads, but to serve as a foundation for automation, AI-assisted operations, and experimentation against realistic network functions.

Deployment follows two phases:

1. **Provision** — OpenTofu creates AWS infrastructure, installs Argo CD, and bootstraps the Kubernetes platform
2. **Operate** — the [Telco Deployment Assistant](https://github.com/5g-cloud-labs/telco-deployment-assistant) deploys and validates telecom workloads via natural-language chat at `https://console.<your-domain>`

---

## What this repository provides

**Infrastructure and platform** (`infrastructure/`, `cluster-bootstrap/`)

- OpenTofu — AWS infrastructure (VPC, EKS, persistent storage, IAM, TLS)
- Multi-interface networking — Multus CNI and dedicated ENIs for 3GPP traffic separation (N2, N3, N4, N6)
- Argo CD — GitOps bootstrap of cluster platform services
- Istio, cert-manager, and external DNS — ingress, service mesh, and automated TLS
- Prometheus, Grafana, and Loki — metrics, dashboards, and log aggregation
- Argo Workflows — multi-step telecom deployment orchestration

**Telecom workloads** (`5g/`) — *deployed on demand, not at install time*

- free5GC — 5G Core network functions (AMF, SMF, UPF, UDM, UDR, and others)
- Subscriber provisioning — automated test subscriber creation
- UERANSIM — gNodeB and UE simulation for registration and data-plane testing

**Experiments**

- [Telco Deployment Assistant](https://github.com/5g-cloud-labs/telco-deployment-assistant) — AI-assisted deployment, parameter collection, and operational validation (Amazon Bedrock). Deployed from this repo as the `ai-agent` service during cluster bootstrap.

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

## Repository structure

```text
.
├── infrastructure/     OpenTofu — AWS infrastructure, EKS, Argo CD bootstrap
├── cluster-bootstrap/  Argo CD apps — platform add-ons and ai-agent
├── 5g/                 Helm charts, Argo CD apps, workflows — telecom payloads
└── docs/               Installation guides and architecture diagrams
```

---

## Getting started

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

After cluster bootstrap syncs in Argo CD:

1. Open `https://console.<your-domain>`
2. Deploy via the Telco Deployment Assistant — for example:

   *"Deploy the full 5G solution with MCC 602, MNC 02, and 10 subscribers"*

3. Validate connectivity and explore automation workflows

### Documentation

| Guide | Description |
|-------|-------------|
| [docs/](docs/) | Documentation index |
| [Installation — infrastructure](docs/installation-instructions/00%20infrastructure.md) | OpenTofu provisioning and bootstrap validation |
| [Telco Deployment Assistant](docs/installation-instructions/01%20ai-agent-console.md) | Deploy and validate telecom workloads |
| [Architecture diagrams](docs/arch/) | VPC, EKS, CNI, and ingress design |
| [Terminate environment](docs/installation-instructions/terminate.md) | Tear down AWS resources |

---

## Related repositories

| Repository | Description |
|------------|-------------|
| [`telco-deployment-assistant`](https://github.com/5g-cloud-labs/telco-deployment-assistant) | AI assistant source — Bedrock intent, workflow selection, and operator chat |
| `5g-platform-gcp` | GCP laboratory *(future)* |

---

## Contributing

Contributions, ideas, and experiments are welcome. Please open an issue or pull request to discuss improvements, bug fixes, or new ideas.

---

## License

Apache License 2.0 — see [LICENSE](LICENSE).

---

## Links

- 🌐 [5G Cloud Labs](https://5gcloudlabs.ai)
- 📧 info@5gcloudlabs.ai
