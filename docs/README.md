# Documentation — 5G Platform AWS

Reference documentation for the [5G Cloud Labs](https://5gcloudlabs.ai) **AWS platform environment**.

This repository is a **platform environment** — used to integrate and evaluate automation and AI use cases against a reproducible 5G network environment. Many contributions begin in dedicated use case repositories and are validated here through end-to-end evaluation. Deploying the full laboratory is not required for all contributors.

Running the full laboratory on AWS costs approximately **USD 3.50–4.00 per hour** in AWS usage, or **~USD 4.50 per hour** including applicable taxes (~16.6%). See [Cost](./installation-instructions/00%20infrastructure.md#cost) in the infrastructure installation guide for details.

## Guides

| Guide | Description |
|-------|-------------|
| [Infrastructure installation](./installation-instructions/00%20infrastructure.md) | Platform provisioning, prerequisites, cost estimate, and bootstrap validation |
| [Network deployment](./installation-instructions/01%20ai-agent-console.md) | Network component deployment and validation via the Network Deployment Agent |
| [Architecture](./arch/) | Platform and network design |
| [Teardown](./installation-instructions/terminate.md) | Resource cleanup |

## Repository layout

| Directory | Role |
|-----------|------|
| `infrastructure/` | Cloud infrastructure provisioning (OpenTofu) |
| `cluster-bootstrap/` | Kubernetes platform services and operational tooling |
| `5g/` | Network components, automation workflows, and deployment manifests |

## Typical workflow

**For end-to-end evaluation on a deployed platform:**

1. **Provision** — `tofu apply` in `infrastructure/`
2. **Bootstrap** — wait for Argo CD to sync `cluster-bootstrap`
3. **Operate** — use the Network Deployment Agent to deploy network components
4. **Validate** — confirm registration, connectivity, and use case behaviour

**For use case development:** work in a dedicated use case repository or on your workstation first; use the steps above when you need validation on AWS.

Maintained by **5G Cloud Labs** — info@5gcloudlabs.ai
