# Subscriber provisioning — Argo CD Application

Part of **5G Platform AWS** — network components layer of the AWS platform environment.

Subscriber provisioning used for **end-to-end evaluation**. Not synced at cluster bootstrap; applied on demand by the Network Deployment Agent or Argo Workflows.

---

## Overview

| Field | Value |
|-------|-------|
| Path | `5g/k8s-resources/sub-prov-job` |
| Namespace | `free5gc` (Job) |
| Parameters | MCC, MNC, and subscriber count via Kustomize patches |

IMSI numbering starts at `{MCC}{MNC}0000000001`.

---

## Deployment flow

```text
User → Network Deployment Agent (Bedrock / Claude Haiku 4.5)
  → kubectl apply or Argo Workflow step
  → sub-prov Job runs
  → subscribers registered in MongoDB / WebUI
```

See [Network deployment guide](../../docs/installation-instructions/01%20ai-agent-console.md).

Maintained by **5G Cloud Labs**.
