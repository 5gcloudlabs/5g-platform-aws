# 5G Platform AWS

**AWS platform environment for the 5G Cloud Labs integration laboratory.**

Part of the **5G Cloud Labs** project.

5G Cloud Labs is an open-source R&D platform for developing, integrating, and evaluating network automation and AI use cases using reproducible cloud-based 5G network environments.

For the project-wide contributor model, repository roles, and development workflow, see the [5G Cloud Labs organization profile](https://github.com/5gcloudlabs).

---

## Overview

This repository deploys a reproducible Kubernetes-based 5G network environment on **Amazon EKS**.

It is the first platform environment within 5G Cloud Labs, providing a reproducible integration laboratory where automation and AI use cases can be evaluated using a 5G network environment comprising a Free5GC core with simulated radio access and user equipment.

Deployment follows two phases:

1. **Provision** — OpenTofu creates AWS infrastructure, installs Argo CD, and bootstraps the Kubernetes platform.
2. **Operate** — the Network Deployment Agent provides a natural language interface for deploying and provisioning network components running on the platform.

The platform is intentionally designed so that network components are deployed on demand rather than during cluster installation.

You do not need to deploy this environment to contribute to every use case. Development can begin in a dedicated use case repository or on your workstation and move here when ready for end-to-end evaluation on AWS.

---

## Why This Repository Exists

Its purpose is not simply to deploy a 5G network environment on AWS.

Instead, it provides a reproducible integration laboratory where automation and AI use cases can be developed, integrated, and evaluated against realistic 5G network scenarios.

Use cases are typically developed in their own repositories, then integrated into this environment when they are ready for end-to-end evaluation.

The AWS platform provides the infrastructure, platform services, observability, networking, and network components required to perform that evaluation.

---

## What Is In This Repository

### Infrastructure and Platform

#### Infrastructure Provisioning (`infrastructure/`)

Provisioned using OpenTofu:

- AWS VPC
- Amazon EKS
- EFS storage
- Load Balancer
- TLS Certification management
- IAM & SSM configuration

#### Platform Services (`cluster-bootstrap/`)

- Argo CD
- Argo Workflows
- Multus CNI
- Whereabouts IPAM
- Ingress
- External DNS + Cloudflare integration
- Cert-Manager + Let's Encrypt integration
- Istio Gateway
- Istio Service Mesh
- Prometheus, Grafana, Loki
- Network Deployment Agent

These services provide the platform foundation required to host network components, automation workflows, and operational tooling.

---

### Network Components and Workflows (`5g/`)

Network components are deployed on demand rather than during initial platform installation.

The laboratory currently supports:

- Free5GC 5G Core
- Subscriber provisioning
- UERANSIM gNodeB and UE simulation
- Deployment automation workflows

The workflow layer supports automated deployment of the 5G Core, subscriber provisioning, and deployment of UERANSIM simulations.

Based on user intent, integrated use cases such as the Network Deployment Agent can either deploy individual network components directly or invoke workflows that coordinate multiple deployment and provisioning tasks through a natural language interface.

Together, these components and workflows provide a reproducible 5G network environment that can be used to evaluate AI and automation use cases and perform end-to-end testing of 5G network scenarios.

---

## Operating the Laboratory

The Network Deployment Agent provides the primary interface for deploying and provisioning network components within the AWS laboratory.

The agent uses a large language model (LLM) to translate user intent into deployment and provisioning actions. Depending on the requested operation, it may deploy individual network components directly or invoke automation workflows that coordinate multiple deployment and provisioning tasks.

Once the platform environment has been provisioned and validated, users can interact with the agent through its web interface to deploy the 5G Core, provision subscribers, and deploy UERANSIM simulations.

The agent is intended to simplify deployment and provisioning workflows. Platform administration, troubleshooting, and advanced validation can still be performed through standard Kubernetes and AWS tooling when required.

The Network Deployment Agent is developed independently in the `network-deployment-agent` repository and integrated into the platform during deployment.

Additional use cases and operational tooling may be integrated into the laboratory over time.

---

## Architecture

```text

          User

             │
      Provision Platform
             │
      OpenTofu + CLI
             │
             ▼
      AWS Infrastructure
             │
             ▼
           Amazon EKS
             │
             ▼
      Platform Services
             │
             ▼
      Network Deployment Agent
             │
             ▼
      Network Components

```

The Network Deployment Agent provides a natural language interface for deploying and provisioning network components after the platform environment has been provisioned and validated. Depending on the requested operation, the agent may deploy individual components directly or invoke automation workflows that coordinate multiple deployment and provisioning tasks.
---

## Repository Structure

```text
.
├── infrastructure/
│   └── Cloud infrastructure provisioning (OpenTofu)
│
├── cluster-bootstrap/
│   └── Kubernetes platform services and operational tooling
│
├── 5g/
│   └── Network components, automation workflows, and deployment manifests
│
└── docs/
    └── Installation guides, architecture, and operations
```

---

## Deployment Workflow

### Phase 1 — Provision

Provision the platform environment:

1. Configure OpenTofu variables.
2. Create AWS infrastructure.
3. Deploy Amazon EKS.
4. Install Argo CD.
5. Bootstrap platform services.

At this stage the platform environment is ready, but network components have not yet been deployed.

---

### Phase 2 — Operate

Use the Network Deployment Agent to deploy and provision network components through a natural language interface.

Example:

```text
Deploy the full 5G solution with MCC 602, MNC 02, and 10 subscribers
```

The agent translates user intent into deployment and provisioning actions, invoking individual component deployments or automation workflows as required.

Typical workflow:

1. Deploy the 5G Core.
2. Provision subscribers.
3. Deploy UERANSIM.
4. Validate registration and connectivity.
5. Perform experimentation and testing.

---

## Cost

The laboratory incurs AWS charges while it is running.

Based on current testing and observed usage:

| Item | Approximate Rate |
|--------|--------|
| AWS usage | USD 3.50–4.00 / hour |
| Tax (~16.6%) | Applied to AWS charges |
| **Estimated total** | **~USD 4.50 / hour** |

Additional costs may be incurred by integrated services or cloud APIs used by individual use cases.

Tear down the environment when not in use.

---

## Getting Started

### Prerequisites

- AWS account
- Domain name and DNS access
- AWS CLI
- OpenTofu
- kubectl

Additional prerequisites may be required by individual use cases.

---

### Quick Start

```bash
git clone https://github.com/5gcloudlabs/5g-platform-aws.git
cd 5g-platform-aws/infrastructure

tofu init
tofu apply
```

Once platform bootstrap is complete:

1. Access the Network Deployment Agent.
2. Deploy network components through the agent.
3. Validate platform operation.

---

## Documentation

| Guide | Description |
|---------|-------------|
| [`docs/`](docs/) | Documentation index |
| [Infrastructure installation](docs/installation-instructions/00%20infrastructure.md) | Platform provisioning and bootstrap |
| [Network deployment](docs/installation-instructions/01%20network-deployment.md) | Component deployment and validation |
| [Architecture](docs/arch/) | Platform and network design |
| [Teardown](docs/installation-instructions/terminate.md) | Resource cleanup |

---

## Contributing To This Repository

Changes in this repository affect the AWS platform environment itself.

Typical examples include:

- OpenTofu infrastructure
- Platform bootstrap components
- Network components
- Integration wiring between use cases and the platform

| Change Type | Recommended Workflow |
|------------|----------------------|
| Platform infrastructure | Develop locally where possible, then validate in a deployed laboratory |
| Network components | Validate against a running platform environment |
| Use case implementation | Develop within the relevant use case repository |
| Use case integration | Integrate and validate within this repository |

For the broader project model, see the [5G Cloud Labs organization profile](https://github.com/5gcloudlabs).

---

## Related Repositories

| Repository | Role |
|------------|------|
| [`network-deployment-agent`](https://github.com/5gcloudlabs/network-deployment-agent) | AI-assisted network deployment and provisioning interface |
| `5g-platform-gcp` | Future platform environment |

---

## License

Apache License 2.0

---

## Maintainer

**5G Cloud Labs**

🌐 Website: 5gcloudlabs.ai

📧 Contact: info@5gcloudlabs.ai

---

## Project Vision

5G Platform AWS is the first platform environment within 5G Cloud Labs.

As additional platform environments become available, the same integration model can be applied across multiple cloud providers. This enables use cases to be developed independently and evaluated consistently across comparable 5G network environments.
