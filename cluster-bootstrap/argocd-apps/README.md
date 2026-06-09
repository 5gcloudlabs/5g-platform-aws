# Argo CD Applications

Argo CD `Application` manifests for **5G Platform AWS**.

## Directories

| Path | Description |
|------|-------------|
| `cluster-bootstrap/argocd-apps/required-apps/` | Platform bootstrap (Istio, Multus, observability, argo-workflows, ai-agent, and others). Synced automatically after OpenTofu apply. |
| `5g/argocd-apps/` | Telecom workload wrappers (free5GC, sub-prov, UERANSIM). Deployed on demand via the Telco Deployment Assistant or Argo Workflows — not at cluster bootstrap. |

## Telecom deployment model

Telecom applications are not pre-synced at install time. The Telco Deployment Assistant (`ai-agent`):

1. Parses user intent via Amazon Bedrock (Anthropic Claude Haiku 4.5)
2. Fetches the relevant manifest from this repository
3. Applies a single Argo CD Application (`kubectl`) or submits an Argo Workflow (multi-step)

See [Telco Deployment Assistant guide](../../docs/installation-instructions/01%20ai-agent-console.md).
