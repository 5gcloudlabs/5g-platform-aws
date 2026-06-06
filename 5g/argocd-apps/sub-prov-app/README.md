# Subscriber provisioning — Argo CD Application

Part of **5G Platform AWS** — telecom layer.

## Purpose

Argo CD `Application` wrapper for the subscriber provisioning Job at `5g/k8s-resources/sub-prov-job/`. Creates test subscribers in free5GC via the WebUI API.

Not synced at cluster bootstrap. Applied on demand by the Telco Deployment Assistant or as a step in Argo Workflows (`5gcore-sub-prov-wf`, `5g-solution-wf`, `sub-prov-ueransim-wf`).

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
User → Telco Deployment Assistant (Bedrock)
  → kubectl apply or Argo Workflow step
  → sub-prov Job runs
  → subscribers registered in MongoDB / WebUI
```

See [Telco Deployment Assistant guide](../../docs/installation-instructions/01%20ai-agent-console.md).

Maintained by **5G Cloud Labs**.
