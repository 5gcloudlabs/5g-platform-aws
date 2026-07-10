# Console Chart (Deprecated)

This Helm chart is no longer used. The operator interface is the **Network Deployment Agent** (`cluster-bootstrap/helm-charts/ai-agent/`), whose application logic is maintained in the [`network-deployment-agent`](https://github.com/5gcloudlabs/network-deployment-agent) repository.

External traffic to `https://console.<domain>` is routed by Istio to `ai-agent-frontend` in the `ai-agent` namespace (see `cluster-bootstrap/k8s-resources/istio/virtual-services/istio-vs-console.yaml`).

Retained for reference only; may be removed in a future release.
