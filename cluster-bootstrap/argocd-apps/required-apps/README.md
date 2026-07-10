# Required Apps — Argo CD Application of Applications

Cluster-bootstrap child applications for **5G Platform AWS**, deployed by Argo CD after OpenTofu provisioning.

These are **platform services** that make up the AWS platform environment — networking, ingress, observability, workflow orchestration, and the Network Deployment Agent console. They are synced automatically so use cases can be validated against a consistent Kubernetes foundation.

The parent Application is defined in `infrastructure/argocd.tf` and points at `cluster-bootstrap/argocd-apps/required-apps/`.

---

## Purpose

OpenTofu creates the EKS cluster and installs Argo CD. Cluster bootstrap then syncs these required platform add-ons:

| Application | Purpose |
|-------------|---------|
| `aws-efs-csi-driver` | EFS persistent volumes |
| `aws-load-balancer-controller` | ALB for Ingress |
| `cert-manager` (+ resources) | TLS certificates |
| `cloudflare-token-secret` | DNS provider credentials |
| `external-dns` | Automatic DNS records |
| `istio-base` / `istiod` / `istio-gateway` | Service mesh |
| `ingress` / `gateway` / `virtual-services` | External access routing |
| `multus` / `whereabouts` | Multi-NIC networking and IPAM |
| `kube-prometheus-stack` / `loki` | Metrics, dashboards, logs |
| `storage-class` | EFS StorageClass |
| `argo-workflows` | Multi-step network deployment orchestration |
| `ai-agent` | Network Deployment Agent (Bedrock / Claude Haiku 4.5 console) |

Network components (Free5GC, UERANSIM, subscriber provisioning) are not part of cluster bootstrap. They are deployed on demand via the Network Deployment Agent, which triggers Argo CD Applications and Argo Workflows under `5g/`.

---

## Deployment flow

```text
OpenTofu apply
  → EKS cluster + Argo CD install
  → cluster-bootstrap Application created
  → required-apps synced (platform add-ons)
  → user opens https://console.<domain>
  → Network Deployment Agent deploys network components from 5g/
```

---

## envsubst plugin

Manifests in this directory use `${ARGOCD_ENV_*}` placeholders. The envsubst CMP plugin (configured in `infrastructure/argocd.tf`) substitutes values passed from OpenTofu (region, domain, cert ARN, IAM ARNs, Bedrock region and Claude Haiku 4.5 model ID).
