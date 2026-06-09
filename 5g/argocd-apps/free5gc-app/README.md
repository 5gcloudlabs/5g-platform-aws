# free5GC Argo CD Application

Part of **5G Platform AWS** — telecom layer.

## Purpose

Argo CD `Application` wrapper for the [free5GC Helm chart](../../helm-charts/free5gc). Deploys the free5GC 5G Core into the `free5gc` namespace.

Not synced at cluster bootstrap. Applied on demand by the Telco Deployment Assistant (single-step) or an Argo Workflow (multi-step).

---

## Overview

| Field | Value |
|-------|-------|
| Helm path | `5g/helm-charts/free5gc` |
| Release name | `aws-5gcloudlabs` |
| Namespace | `free5gc` |
| Parameters | MCC and MNC via envsubst (`${ARGOCD_ENV_MCC}`, `${ARGOCD_ENV_MNC}`) |

Network functions: AMF, AUSF, NRF, NSSF, PCF, SMF, UDM, UDR, UPF, WebUI, MongoDB.

---

## Deployment flow

```text
User → Telco Deployment Assistant (Bedrock / Claude Haiku 4.5)
  → kubectl apply (patched Application YAML)
  → Argo CD syncs Helm chart
  → free5GC pods in free5gc namespace
```

Or as the first step of workflows `5gcore-sub-prov-wf` / `5g-solution-wf`.

---

## References

- [free5GC Helm chart](../../helm-charts/free5gc)
- [free5GC](https://free5gc.org/)
- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) (upstream, Apache 2.0)

Maintained by **5G Cloud Labs**.
