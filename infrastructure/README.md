# Infrastructure

OpenTofu configuration for **5G Platform AWS** — the reference telecom laboratory on AWS.

This directory provisions AWS infrastructure (including the EKS cluster), installs Argo CD, and registers the cluster-bootstrap Application. Argo CD then syncs required platform add-ons from `cluster-bootstrap/argocd-apps/required-apps/` — for example Istio, ingress, Multus, observability, argo-workflows, and the Telco Deployment Assistant (`ai-agent`).

Telecom workloads under `5g/` are deployed later via the assistant, not during `tofu apply`.

---

## OpenTofu files

| File | Description |
|------|-------------|
| `providers.tf` | Provider configuration (AWS, Kubernetes, Helm, kubectl, Cloudflare), S3 backend |
| `variables.tf` | Input variables (region, VPC, EKS, DNS, Bedrock / Claude Haiku 4.5) |
| `vars.auto.tfvars` | Environment-specific variable values (not committed with secrets in production) |
| `vpc.tf` | VPC, subnets, NAT, secondary CIDR (`100.64.0.0/16`), N6 route table |
| `eks.tf` | EKS cluster, control-plane and user-plane node groups, VPC CNI tuning, Istio webhook SG rules |
| `multus.tf` | Multus subnets, ENIs, attachments, and security groups for N2/N3/N4/N6 |
| `ssm.tf` | SSM documents to bring secondary ENIs up on worker nodes |
| `efs.tf` | Amazon EFS for persistent volumes (MongoDB) |
| `iam.tf` | IRSA roles for ALB controller, EFS CSI driver, and ai-agent Bedrock access (Claude Haiku 4.5) |
| `acm.tf` | ACM certificate with Cloudflare DNS validation |
| `argocd.tf` | Argo CD Helm release (envsubst CMP plugin) and cluster-bootstrap Application |
| `k8s_git-repo-secret.tf` | Git credential secret for Argo CD repository access |

---

## Provision vs. operate

| Phase | Tool | Scope |
|-------|------|-------|
| AWS infrastructure | OpenTofu | VPC, EKS cluster and nodes, ENIs, EFS, ACM, IAM, Argo CD install |
| Cluster bootstrap | Argo CD | Required add-ons under `required-apps/` (Istio, ingress, Multus, observability, argo-workflows, ai-agent, etc.) |
| Telecom workloads | Telco Deployment Assistant | free5GC, subscriber provisioning, UERANSIM (via Argo CD / Argo Workflows) |

Only Argo CD is installed directly by OpenTofu via Helm. Other cluster add-ons are Argo CD Applications under `cluster-bootstrap/argocd-apps/required-apps/`.

---

## Cost

Provisioning creates billable AWS resources. Based on observed billing, the running laboratory averages approximately **USD 3.50–4.00 per hour** in AWS usage, or **~USD 4.50 per hour** including applicable taxes (~16.6%). See the [Cost section](../docs/installation-instructions/00%20infrastructure.md#cost) in the installation guide for a breakdown and [terminate.md](../docs/installation-instructions/terminate.md) to tear down when finished.

---

## Usage

```bash
git clone https://github.com/5gcloudlabs/5g-platform-aws.git
cd 5g-platform-aws/infrastructure
tofu init
tofu plan
tofu apply
```

See [Installation instructions](../docs/installation-instructions/00%20infrastructure.md) for prerequisites and validation.
