
## Installation Instructions — Infrastructure

Part of **5G Platform AWS** — reference implementation of the 5G Cloud Labs telecom laboratory.

This guide covers prerequisites and OpenTofu provisioning (Phase 1). After cluster bootstrap completes, use the [Telco Deployment Assistant](./01%20ai-agent-console.md) to deploy and validate telecom workloads (Phase 2).

---

### 1. Prerequisites

#### 1.a) Cloud account requirements

| Requirement | Description |
|-------------|-------------|
| **AWS Account** | Permissions to create VPC, EKS, EC2, EFS, ACM, IAM, SSM, and S3 resources. |
| **Cloudflare Account** | A registered domain, zone ID, and API token with **DNS:Edit** permissions for that zone. |
| **Amazon Bedrock access** | Model access enabled for **Anthropic Claude Haiku 4.5** in the AWS account/region used by the Telco Deployment Assistant (see [Bedrock model access](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html) and the [Claude Haiku 4.5 model card](https://docs.aws.amazon.com/bedrock/latest/userguide/model-card-anthropic-claude-haiku-4-5.html)). |

#### 1.b) Local workstation requirements

| Tool | Installation |
|------|--------------|
| **AWS CLI** | [Install guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| **OpenTofu** | [Install guide](https://opentofu.org/docs/intro/install/) |
| **kubectl** | [Install guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/) |

Verify:

```bash
aws --version
tofu version
kubectl version --client
```

#### 1.c) Configure AWS credentials

Configure credentials via `aws configure` or environment variables:

```bash
export AWS_ACCESS_KEY_ID="<access-key>"
export AWS_SECRET_ACCESS_KEY="<secret-key>"
export AWS_REGION="<region>"
```

#### 1.d) Create an S3 bucket for OpenTofu state

For `us-east-1`:

```bash
aws s3api create-bucket --bucket <bucket-name>
```

For other regions:

```bash
aws s3api create-bucket --bucket <bucket-name> \
  --create-bucket-configuration LocationConstraint=$AWS_REGION
```

---

### 2. Clone the repository

```bash
git clone https://github.com/5gcloudlabs/5g-platform-aws.git
cd 5g-platform-aws/infrastructure
```

---

### 3. Set OpenTofu input variables

Edit `vars.auto.tfvars`:

| Variable | Default / example | Description |
|----------|-------------------|-------------|
| `region` | `eu-central-1` | AWS region for all resources. |
| `bucket-name` | *(required)* | S3 bucket for OpenTofu remote state. |
| `key` | `state/iac.tfstate` | State file path inside the bucket. |
| `vpc_name` | `cloud-5g-vpc` | VPC name. |
| `vpc_cidr` | `192.168.0.0/16` | Primary VPC CIDR. |
| `azs` | `["eu-central-1b", "eu-central-1c"]` | Availability zones. |
| `eks_cluster_name` | `cloud-5g-eks` | EKS cluster name. |
| `ami_id` | region-specific Ubuntu EKS AMI | Worker node AMI ([reference](https://cloud-images.ubuntu.com/docs/aws/eks/)). |
| `domain_name` | *(required)* | Public domain (e.g. `5gcloudlabs.ai`). |
| `zone_id` | *(required)* | Cloudflare zone ID. |
| `cloudflare_api_token` | *(required)* | Cloudflare API token for DNS and ACM validation. |
| `bedrock_region` | `""` | Bedrock region override; empty uses `region`. |
| `bedrock_model_id` | Anthropic Claude Haiku 4.5 (see `variables.tf`) | Bedrock model or inference profile ID for the Telco Deployment Assistant. |

---

### 4. Provision infrastructure with OpenTofu

OpenTofu provisions AWS resources (including the EKS cluster), installs Argo CD, and creates the cluster-bootstrap Application. Argo CD then syncs the required platform add-ons from `cluster-bootstrap/argocd-apps/required-apps/`.

#### 4.a) Initialize

```bash
cd 5g-platform-aws/infrastructure
tofu init
```

#### 4.b) Plan and apply

```bash
tofu plan
tofu apply
```

Confirm with `yes` when prompted. A fresh deployment typically adds on the order of ~140 resources (exact count varies with provider versions).

**What `tofu apply` does:**

- Creates VPC, subnets, NAT, secondary CIDR (`100.64.0.0/16`), EKS cluster, and two node groups (control-plane and user-plane)
- Attaches Multus ENIs and security groups for N2/N3/N4/N6 interfaces
- Creates EFS, ACM certificate (DNS-validated via Cloudflare), and IAM roles (ALB controller, EFS CSI, ai-agent Bedrock access for Claude Haiku 4.5)
- Installs Argo CD (Helm) with the envsubst CMP plugin
- Registers the Git repository secret and applies the cluster-bootstrap Argo CD Application

#### 4.c) Validate AWS resources

```bash
aws ec2 describe-vpcs
aws ec2 describe-subnets
aws acm list-certificates
aws efs describe-file-systems
```

#### 4.d) Configure kubectl and verify nodes

```bash
aws eks update-kubeconfig --region "$AWS_REGION" --name "<EKS_CLUSTER_NAME>"
kubectl get nodes
```

Expect **two** worker nodes in `Ready` state (control-plane and user-plane node groups).

#### 4.e) Verify cluster bootstrap (Argo CD)

Wait until the parent application and its children are **Synced** and **Healthy**:

```bash
kubectl -n argocd get applications
```

Expected applications include (non-exhaustive):

| Application | Purpose |
|-------------|---------|
| `cluster-bootstrap` | Parent app-of-apps |
| `ai-agent` | Telco Deployment Assistant — frontend + backend (Bedrock / Claude Haiku 4.5) |
| `argo-workflows` | Workflow engine for multi-step 5G deployments |
| `aws-load-balancer-controller` | ALB provisioning |
| `aws-efs-csi-driver` | EFS persistent volumes |
| `cert-manager` / `cert-manager-*` | TLS certificate automation |
| `external-dns` | Cloudflare DNS records |
| `istio-base` / `istiod` / `istio-gateway` | Service mesh and ingress |
| `ingress` / `gateway` / `virtual-services` | External routing |
| `multus` / `whereabouts` | Multi-NIC networking and IPAM |
| `kube-prometheus-stack` / `loki` | Observability |
| `storage-class` | EFS-backed `efs-sc` StorageClass |

Verify key namespaces:

```bash
kubectl -n ai-agent get pods
kubectl -n argo get pods
kubectl -n kube-system get pods
kubectl -n istio-system get pods
kubectl -n monitoring get pods
```

The Telco Deployment Assistant pods (`ai-agent-frontend`, `ai-agent-backend`) should reach `Running`.

#### 4.f) Validate ingress and DNS

```bash
kubectl -n istio-system describe ingress ingress
```

Expected host rules:

| Host | Service |
|------|---------|
| `console.<domain>` | Telco Deployment Assistant |
| `argocd.<domain>` | Argo CD UI |
| `grafana.<domain>` | Grafana |
| `free5gc.<domain>` | free5GC WebUI |
| `prometheus.<domain>` | Prometheus |

Confirm the ALB hostname in the **Address** field resolves:

```bash
dig +short <alb-hostname-from-ingress>
```

---

### 5. Next step — deploy the 5G network

Infrastructure and platform bootstrap are complete. Continue with:

[Deploy and validate the telecom environment via the Telco Deployment Assistant](./01%20ai-agent-console.md)

---

### 6. Tear down

See **[terminate.md](./terminate.md)**.
