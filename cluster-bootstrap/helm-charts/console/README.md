# Console Chart (Deprecated)

This Helm chart is no longer used. The operator interface is the **Telco Deployment Assistant** (`cluster-bootstrap/helm-charts/ai-agent/`).

External traffic to `https://console.<domain>` is routed by Istio to `ai-agent-frontend` in the `ai-agent` namespace (see `cluster-bootstrap/k8s-resources/istio/virtual-services/istio-vs-console.yaml`).

Retained for reference only; may be removed in a future release.
