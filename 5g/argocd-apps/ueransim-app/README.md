# UERANSIM Argo CD Application

Part of **5G Platform AWS** — network components layer of the AWS platform environment.

RAN and UE simulation used for **end-to-end evaluation**. Not synced at cluster bootstrap; applied on demand by the Network Deployment Agent or Argo Workflows.

---

## Overview

| Field | Value |
|-------|-------|
| Helm path | `5g/helm-charts/ueransim` |
| Release name | `aws-5gcloudlabs` |
| Namespace | `ueransim` |
| Parameters | MCC, MNC, and UE count via envsubst / Helm values |

---

## Deployment flow

```text
User → Network Deployment Agent (Bedrock / Claude Haiku 4.5)
  → kubectl apply or Argo Workflow step
  → Argo CD syncs Helm chart
  → gNB + UE pods in ueransim namespace
```

---

## References

- [UERANSIM Helm chart](../../helm-charts/ueransim)
- [UERANSIM](https://github.com/aligungr/UERANSIM)
- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) (upstream, Apache 2.0)

Maintained by **5G Cloud Labs**.
