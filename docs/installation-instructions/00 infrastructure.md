
## Installation Instructions — Infrastructure

Part of **5G Platform AWS** — the AWS platform environment within [5G Cloud Labs](https://5gcloudlabs.ai).

This guide covers prerequisites and OpenTofu provisioning (Phase 1) for contributors who need a **deployed platform environment** for end-to-end evaluation. After cluster bootstrap completes, use the [Network Deployment Agent](./01%20network-deployment.md) to deploy and validate network components (Phase 2).

If you are developing a use case or experiment in a dedicated repository, you do not need to follow this guide until you are ready for end-to-end validation on AWS.

---

## Cost

The laboratory runs on billable AWS resources for as long as it remains provisioned. Based on observed billing, the **average running cost is approximately USD 3.50–4.00 per hour** in AWS charges — primarily EKS, EC2 worker nodes, networking, load balancers, and storage.

With applicable taxes (approximately **16.6%** on AWS charges in the reference deployment), the **estimated all-in cost is around USD 4.50 per hour**.

| Item | Approximate rate |
|------|------------------|
| AWS usage | USD 3.50–4.00 / hour |
| Tax (~16.6%) | applied to AWS charges |
| **Estimated total** | **~USD 4.50 / hour** |

Actual costs vary by AWS region, instance hours, and data transfer. Amazon Bedrock usage for the Network Deployment Agent is billed separately on a per-request basis and is typically small compared to infrastructure charges.

**Tear down the environment when it is not in use** to avoid ongoing hourly charges. See [Terminate environment](./terminate.md).

---

### 1. Prerequisites

#### 1.a) Cloud account requirements

| Requirement | Description |
|-------------|-------------|
| **AWS Account** | Permissions to create VPC, EKS, EC2, EFS, ACM, IAM, SSM, and S3 resources. |
| **Cloudflare Account** | A registered domain, zone ID, and API token with **DNS:Edit** permissions for that zone. |

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

#### 1.e) Submit Anthropic use case for Bedrock

Anthropic models on Amazon Bedrock require a **one-time first-time use (FTU) form** per AWS account before the Network Deployment Agent can invoke Claude Haiku 4.5. See [Bedrock model access](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html) and [`PutUseCaseForModelAccess`](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_PutUseCaseForModelAccess.html).

Replace the placeholder values in the JSON below, then run:

| Field | Description |
|-------|-------------|
| `companyName` | Organization or contributor name. |
| `companyWebsite` | Company or project URL (portfolio, GitHub profile, or project page if you have no company site). |
| `intendedUsers` | `0` = internal only, `1` = external, `2` = internal and external. |
| `industryOption` | Industry category (for example, `Technology`). |
| `otherIndustryOption` | Optional; use when your industry is not listed. |
| `useCases` | Brief description of how you will use Anthropic models on Bedrock. |

```bash
aws bedrock put-use-case-for-model-access \
  --region us-east-1 \
  --form-data "$(printf '%s' '{
    "companyName": "Your Company",
    "companyWebsite": "https://example.com",
    "intendedUsers": "0",
    "industryOption": "Technology",
    "otherIndustryOption": "",
    "useCases": "Deploy, provision and validate 5G network components on Amazon EKS using the Network Deployment Agent — a conversational operator interface that interprets natural-language deployment intent via Anthropic Claude on Amazon Bedrock and orchestrates Kubernetes resources and Argo Workflows for end-to-end laboratory evaluation."
  }' | base64)"
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
| `bedrock_model_id` | Anthropic Claude Haiku 4.5 (see `variables.tf`) | Bedrock model or inference profile ID for the Network Deployment Agent. |
| `git_repo_url` | current platform Git URL | Repository URL registered with Argo CD. |
| `git_repo_password` | `""` | Optional Git PAT for private repos; leave empty when the platform repository is public. |

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
- Creates EFS, ACM certificate (DNS-validated via Cloudflare), and IAM roles (ALB controller, EFS CSI, network-deployment-agent Bedrock access for Claude Haiku 4.5)
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
| `network-deployment-agent` | Network Deployment Agent — frontend + backend (Bedrock / Claude Haiku 4.5) |
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
kubectl -n network-deployment-agent get pods
kubectl -n argo get pods
kubectl -n kube-system get pods
kubectl -n istio-system get pods
kubectl -n monitoring get pods
```

The Network Deployment Agent pods (`network-deployment-agent-frontend`, `network-deployment-agent-backend`) should reach `Running`.

#### 4.f) Validate ingress and DNS

```bash
kubectl -n istio-system describe ingress ingress
```

Expected host rules:

| Host | Service |
|------|---------|
| `console.<domain>` | Network Deployment Agent |
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

[Deploy and validate network components via the Network Deployment Agent](./01%20network-deployment.md)

---

### 6. Tear down

See **[terminate.md](./terminate.md)**.
