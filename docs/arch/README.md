# Architecture — 5G Platform AWS

Diagrams for the AWS **platform environment**. They describe infrastructure and networking design for end-to-end evaluation of automation and AI use cases against realistic 5G network scenarios.

Operational deployment on a running platform is via the [Network Deployment Agent](../installation-instructions/01%20ai-agent-console.md).

| Document | Topic |
|----------|-------|
| [a. 5G-Core.md](./a.%205G-Core.md) | Free5GC network functions and interfaces |
| [b. VPC.md](./b.%20VPC.md) | VPC layout, subnets, secondary CIDR |
| [c. EKS.md](./c.%20EKS.md) | EKS cluster and node groups |
| [d. 5G-on-EKS.md](./d.%205G-on-EKS.md) | Network components on Kubernetes |
| [e. CNI-1.md](./e.%20CNI-1.md) | Multus / primary CNI overview |
| [f. CNI-2.md](./f.%20CNI-2.md) | Multus interface details (N2/N3/N4/N6) |
| [g. Ingress.md](./g.%20Ingress.md) | ALB, Istio gateway, external URLs |

## End-to-end flow

```text
Phase 1 — Provision
  OpenTofu → AWS infrastructure + EKS + Argo CD → cluster-bootstrap

Phase 2 — Operate
  Network Deployment Agent (console.<domain>)
    → Argo Workflows / Argo CD apps
    → Free5GC · subscriber provisioning · UERANSIM
```
