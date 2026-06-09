# Helm Charts — Cluster Bootstrap

Locally maintained Helm charts for **5G Platform AWS**, deployed by Argo CD during cluster bootstrap.

| Chart | Description |
|-------|-------------|
| ai-agent | Telco Deployment Assistant — frontend and backend (Amazon Bedrock — Anthropic Claude Haiku 4.5). Console at `console.<domain>`. |
| multus | Multus CNI for multi-interface pod networking (required by telecom workloads). |

---

## Charts outside bootstrap

These charts live under `5g/helm-charts/` and are deployed on demand by the Telco Deployment Assistant (not at cluster bootstrap):

| Chart | Description |
|-------|-------------|
| free5gc | free5GC 5G Core network functions |
| ueransim | gNodeB and UE simulator |

---

## Legacy chart

The console chart in this directory is deprecated. The Istio VirtualService for `console.<domain>` routes to ai-agent-frontend (Telco Deployment Assistant), not the old console deployment.

---

Charts are referenced by Argo CD Application manifests in `cluster-bootstrap/argocd-apps/required-apps/`.
