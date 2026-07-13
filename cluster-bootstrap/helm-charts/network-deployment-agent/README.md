# Network Deployment Agent — Helm Chart

Helm chart for deploying the **Network Deployment Agent** on a 5G Cloud Labs platform environment.

Application source and use case documentation: [`5g-cloud-labs/ai-agent`](https://github.com/5g-cloud-labs/ai-agent).

---

## Overview

This chart deploys the agent as two workloads in the `network-deployment-agent` namespace:

| Workload | Description |
|----------|-------------|
| `network-deployment-agent-frontend` | Chainlit web interface — `https://console.<domain>` |
| `network-deployment-agent-backend` | FastAPI service — intent, orchestration, Bedrock calls |

The chart is synced by Argo CD during cluster bootstrap (`network-deployment-agent` application in `cluster-bootstrap/argocd-apps/required-apps/`).

---

## Configuration

Key values in `values.yaml`:

| Value | Description |
|-------|-------------|
| `image.repository` / `image.tag` | Container image for frontend and backend |
| `serviceAccount.roleArn` | IRSA role ARN for Amazon Bedrock access |
| `config.DOMAIN_NAME` | Platform domain |
| `config.BEDROCK_REGION` | Bedrock API region |
| `config.BEDROCK_MODEL_ID` | Model or inference profile (Claude Haiku 4.5) |
| `config.GITHUB_RAW_BASE` | Platform repo raw URL for deployment manifests |
| `config.ARGO_WF_BASE_PATH` | Argo Workflow path under platform repo |
| `config.ARGOCD_APPS_BASE_PATH` | Argo CD Application path under platform repo |

OpenTofu passes Bedrock and domain settings into this chart via the envsubst plugin and Argo CD application parameters in `infrastructure/argocd.tf`.

---

## Related Documentation

- [Network deployment guide](../../../docs/installation-instructions/01%20network-deployment.md) — operating the agent on a running platform
- [Network Deployment Agent use case README](../../../network-deployment-agent/README.md) — development and architecture

Maintained by **5G Cloud Labs**.
