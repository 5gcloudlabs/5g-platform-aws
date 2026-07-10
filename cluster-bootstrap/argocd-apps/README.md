# Argo CD Applications

Argo CD `Application` manifests for **5G Platform AWS** — the AWS platform environment.

Platform bootstrap applications live under `cluster-bootstrap/argocd-apps/required-apps/`. Network component wrappers live under `5g/argocd-apps/` and provide realistic 5G network functions for end-to-end evaluation.

| Path | Description |
|------|-------------|
| `cluster-bootstrap/argocd-apps/required-apps/` | Platform bootstrap (Istio, Multus, observability, argo-workflows, ai-agent, and others). Synced automatically after OpenTofu apply. |
| `5g/argocd-apps/` | Network component wrappers (Free5GC, sub-prov, UERANSIM). Deployed on demand via the Network Deployment Agent or Argo Workflows — not at cluster bootstrap. |

## Network deployment model

Network components are not pre-synced at install time. The Network Deployment Agent (`ai-agent`):

1. Parses user intent via Amazon Bedrock (Anthropic Claude Haiku 4.5)
2. Fetches the relevant manifest from this repository
3. Applies a single Argo CD Application (`kubectl`) or submits an Argo Workflow (multi-step)

See [Network deployment guide](../../docs/installation-instructions/01%20ai-agent-console.md).
