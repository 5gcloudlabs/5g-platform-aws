# Documentation — 5G Platform AWS

Reference implementation of the [5G Cloud Labs](https://5gcloudlabs.ai) telecom laboratory on AWS.

## Guides

| Document | Description |
|----------|-------------|
| [Installation — infrastructure](./installation-instructions/00%20infrastructure.md) | Prerequisites, OpenTofu apply, cluster bootstrap validation |
| [Telco Deployment Assistant](./installation-instructions/01%20ai-agent-console.md) | Deploy and validate free5GC, subscribers, and UERANSIM via the console |
| [Terminate environment](./installation-instructions/terminate.md) | Tear down AWS resources |

## Architecture

Diagrams and design notes: [docs/arch/](./arch/)

## Repository layout

| Directory | Role |
|-----------|------|
| `infrastructure/` | OpenTofu — AWS infrastructure, EKS, Argo CD bootstrap |
| `cluster-bootstrap/` | Platform add-ons and Telco Deployment Assistant (`ai-agent`) |
| `5g/` | Telecom payloads — Helm charts, Argo CD apps, workflows |

## Typical workflow

1. **Provision** — `tofu apply` in `infrastructure/`
2. **Bootstrap** — wait for Argo CD to sync `cluster-bootstrap`
3. **Operate** — open `https://console.<your-domain>` and use the Telco Deployment Assistant
4. **Experiment** — automation, observability, and AI-assisted operational workflows

Maintained by **5G Cloud Labs** — info@5gcloudlabs.ai
