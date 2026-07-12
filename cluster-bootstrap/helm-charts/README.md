# Helm Charts — Cluster Bootstrap

Locally maintained Helm charts for **5G Platform AWS**, deployed by Argo CD during cluster bootstrap.

These charts support the AWS platform environment. The `network-deployment-agent` chart deploys the Network Deployment Agent console; application logic is developed in the [`network-deployment-agent`](https://github.com/5gcloudlabs/network-deployment-agent) repository.

| Chart | Description |
|-------|-------------|
| network-deployment-agent | Network Deployment Agent — frontend and backend (Amazon Bedrock — Anthropic Claude Haiku 4.5). See [chart README](./network-deployment-agent/README.md) and [use case README](../../../network-deployment-agent/README.md). Console at `console.<domain>`. |
| multus | Multus CNI for multi-interface pod networking (required by network components) |

---

## Charts outside bootstrap

These charts live under `5g/helm-charts/` and are deployed on demand by the Network Deployment Agent (not at cluster bootstrap):

| Chart | Description |
|-------|-------------|
| free5gc | free5GC 5G Core network functions |
| ueransim | gNodeB and UE simulator |

---

Charts are referenced by Argo CD Application manifests in `cluster-bootstrap/argocd-apps/required-apps/`.
