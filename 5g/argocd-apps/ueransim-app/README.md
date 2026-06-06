# UERANSIM Argo CD Application

Part of **5G Platform AWS** — telecom layer.

## Purpose

Argo CD `Application` wrapper for the [UERANSIM Helm chart](../../helm-charts/ueransim). Deploys gNB and UE simulation into the `ueransim` namespace.

Not synced at cluster bootstrap. Applied on demand by the Telco Deployment Assistant or an Argo Workflow after the core and subscribers are in place.

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
User → Telco Deployment Assistant (Bedrock)
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
