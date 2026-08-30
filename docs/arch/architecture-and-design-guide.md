# 5G Platform AWS — Architecture & Design Guide

**Audience:** Engineers, architects, and contributors who want to understand, extend, or integrate with the platform.

**Purpose:** Describe the architecture, design decisions, implementation approach, and operational model of the 5G Platform AWS integration laboratory.

**Companion Documentation**

- [Installation Guides](../installation-instructions/00%20infrastructure.md) — Deployment and operational procedures
- [Repository README](../../README.md) — Project overview
- Architecture & Design Guide (this document) — Technical architecture and implementation
- [Architecture diagrams](./) — Visual reference for individual layers

---

# Document Index

## Part I — Solution Overview

- [1. Introduction](#1-introduction)
- [2. Solution Architecture](#2-solution-architecture)

## Part II — Infrastructure Layer

- [4. VPC](#4-vpc)
- [5. Amazon EKS](#5-amazon-eks)
- [6. Platform Infrastructure](#6-platform-infrastructure)

## Part III — Kubernetes Platform Layer

- [7. Platform Bootstrap](#7-platform-bootstrap)
- [8. Kubernetes Networking](#8-kubernetes-networking)
- [9. Ingress & External Access](#9-ingress--external-access)
- [10. Observability & Storage](#10-observability--storage)

## Part IV — 5G Network Layer

- [11. 5G Network Components](#11-5g-network-components)

## Part V — Operations Layer

- [12. AI Capabilities](#12-ai-capabilities)
- [13. End-to-End Lifecycle](#13-end-to-end-lifecycle)

## Part VI — Reference

- [14. IP Address Plan](#14-ip-address-plan)
- [15. Configuration Reference](#15-configuration-reference)
- [16. Repository Map](#16-repository-map)
- [17. Glossary](#17-glossary)
- [18. References](#18-references)

---

# Part I — Solution Overview

## 1. Introduction

### 1.1 Purpose

5G Platform AWS is the first **platform environment** within [5G Cloud Labs](https://5gcloudlabs.ai): a reproducible Amazon EKS–based integration laboratory where network automation and AI use cases can be developed, integrated, and evaluated against realistic 5G network scenarios.

Its purpose is not only to deploy a 5G core on AWS. It provides the infrastructure, platform services, observability, networking model, and on-demand network components required for end-to-end evaluation.

### 1.2 Scope

This guide covers:

- End-to-end solution architecture
- Infrastructure provisioning with OpenTofu (VPC, EKS, IAM, EFS, ACM, Argo CD install)
- Kubernetes platform bootstrap (Multus, Istio, ingress, observability, agent)
- 5G network components (Free5GC, UERANSIM, subscriber provisioning)
- Operations through the Network Deployment Agent and Argo Workflows
- Reference material (IP plan, configuration, repository map)

It does **not** replace step-by-step install procedures. For those, see the [infrastructure](../installation-instructions/00%20infrastructure.md) and [network deployment](../installation-instructions/01%20network-deployment.md) guides.

### 1.3 Intended Audience

- Engineers extending infrastructure, Helm charts, or workflows
- Architects evaluating the lab for integration or research use
- Contributors building automation or AI capabilities against the platform
- Operators who need to understand *why* the stack is structured as it is

---

## 2. Solution Architecture

### 2.1 System Context

| Actor / System | Role |
|----------------|------|
| Operator | Provisions infrastructure; deploys network components via the agent console |
| Network Deployment Agent | Natural-language / catalog-driven orchestration of 5G deployments |
| Amazon EKS | Hosts platform services and network functions |
| AWS (VPC, IAM, EFS, ACM, Bedrock, …) | Cloud foundation and AI inference |
| Cloudflare | DNS for public hostnames and ACM validation |
| Git (`5gcloudlabs/5g-platform-aws`) | Source of truth for GitOps manifests |

### 2.2 End-to-End Architecture

At a high level the laboratory is composed of:

1. **Infrastructure layer** — VPC (primary + secondary CIDR), EKS with dual node groups, Multus ENIs, IAM/EFS/ACM, Argo CD install  
2. **Kubernetes platform layer** — Multus/Whereabouts, Istio, ingress, observability, Network Deployment Agent  
3. **5G network layer** — Free5GC, UERANSIM, subscriber provisioning (on demand)  
4. **Operations layer** — Agent + Argo Workflows / Argo CD driven by the deployment catalog  

Visual detail for each layer appears in later chapters and in [docs/arch/](./).

### 2.3 Platform Operating Model

```text
Phase 1 — Provision
  OpenTofu → VPC → EKS + ENIs → IAM / EFS / ACM → Argo CD
       → cluster-bootstrap (app-of-apps)

Phase 2 — Operate
  Network Deployment Agent (console.<domain>)
       → Argo Workflows / Argo CD
       → Free5GC · subscribers · UERANSIM
```

Network components are intentionally **not** installed during Phase 1. That keeps the base platform stable and lets operators (or automation) compose scenarios on demand.

### 2.4 Repository Model

| Directory | Responsibility |
|-----------|----------------|
| `infrastructure/` | OpenTofu: cloud resources and Argo CD install |
| `cluster-bootstrap/` | Required Kubernetes platform Applications and charts |
| `5g/` | Network function charts, Argo apps, workflows, deployment catalog |
| `docs/` | Installation guides and this Architecture & Design Guide |

Related application source for the agent lives in [`5gcloudlabs/network-deployment-agent`](https://github.com/5gcloudlabs/network-deployment-agent).

### 2.5 Technology Stack

| Area | Technologies |
|------|----------------|
| IaC | OpenTofu / Terraform AWS modules |
| Compute | Amazon EKS, Ubuntu EKS AMI, dual managed node groups |
| Networking | VPC CNI, Multus, Whereabouts, secondary ENIs |
| GitOps | Argo CD, Argo Workflows |
| Service mesh / ingress | Istio, AWS Load Balancer Controller, external-dns, cert-manager |
| 5G | Free5GC, UERANSIM, `gtp5g` |
| Storage / observability | Amazon EFS, Prometheus, Grafana, Loki |
| AI | Amazon Bedrock (Claude Haiku 4.5), agent IRSA |

### 2.6 Security & Identity Model

- **IRSA** grants least-privilege AWS API access to controllers and the Network Deployment Agent (including Bedrock).  
- **Security groups** restrict Multus ENI traffic to expected reference-point peers; EKS node rules enable Istio webhook and inter-node HTTP where required.  
- **Secrets** such as Cloudflare tokens belong in local `vars.auto.tfvars` (gitignored); the public repository ships an empty example template.  
- **GitOps sources** for the public platform do not require a GitHub token when manifests are fetched from the public repository.

### 2.7 Cost & Operational Blast Radius

The reference deployment in **`eu-central-1`** typically costs about **USD 3.50–4.00 / hour** in AWS usage, or **~USD 4.50 / hour** including applicable taxes (~16.6%). Prices in other regions may vary. Resources remain billable until tear-down; see [terminate.md](../installation-instructions/terminate.md).

---

# Part II — Infrastructure Layer

## 4. VPC

### 4.1 Overview

This chapter describes the AWS networking foundation for the platform environment. Every subsequent component — including Amazon EKS, Multus, Free5GC, and UERANSIM — depends on this networking layer.

The design separates Kubernetes networking from 5G network traffic by assigning them to different IP address spaces:

- **Cluster networking** uses the primary VPC CIDR (`192.168.0.0/16` by default) for Kubernetes pods, services, worker nodes, and ingress traffic.
- **5G networking** uses a dedicated secondary CIDR (`100.64.0.0/16`) from which Multus allocates secondary interfaces for Free5GC and UERANSIM network functions.

This separation allows network functions to expose stable interfaces for 3GPP reference points (N2, N3, N4, and N6) while remaining integrated with the Kubernetes networking model.

---

### 4.2 Architecture

<img width="5559" height="4600" alt="VPC Architecture" src="https://github.com/user-attachments/assets/ca953fea-361b-40f3-81e0-9b701c1b6fb3" />

The VPC consists of two independent networking domains:

- A **primary CIDR** that provides standard AWS and Kubernetes networking.
- A **secondary CIDR** dedicated to Multus-attached interfaces used by 5G network functions.

This architecture enables Kubernetes workloads to operate using the standard VPC CNI while Free5GC and UERANSIM receive deterministic secondary interfaces for 3GPP reference points.

---

### 4.3 Key Components

| Component | Responsibility |
|-----------|----------------|
| **VPC** | Creates the primary networking environment, including public and private subnets |
| **Secondary CIDR** | Provides a dedicated address space for 5G network interfaces |
| **Public Subnets** | Host internet-facing Application Load Balancers |
| **Private Subnets** | Host Amazon EKS worker nodes |
| **Multus Subnets** | Provide dedicated Layer-3 networks for individual 5G interfaces |
| **NAT Gateways** | Provide outbound internet connectivity for private workloads |
| **N6 Route Table** | Routes user-plane traffic from the UPF N6 subnet through the NAT Gateway |

---

### 4.4 Provisioning Workflow

```text
tofu apply
      │
      ▼
Create VPC
(public & private subnets + NAT Gateways)
      │
      ▼
Associate Secondary CIDR
      │
      ▼
Create Multus Subnets
      │
      ▼
Configure N6 Routing
      │
      ▼
VPC Ready
```

NAT Gateways are created as part of the VPC module. Multus subnets and the N6 route table are configured after the secondary CIDR is associated.

The networking infrastructure is provisioned before Amazon EKS worker nodes are created.

Later stages attach secondary Elastic Network Interfaces (ENIs) from the Multus subnets to worker nodes, enabling network functions to receive deterministic secondary IP addresses.

---

### 4.5 Solution Implementation

#### 4.5.1 VPC

The VPC is created using the community `terraform-aws-modules/vpc/aws` module.

```terraform
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.2.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs = [
    "eu-central-1b",
    "eu-central-1c"
  ]

  public_subnets = [
    cidrsubnet(var.vpc_cidr, 3, 0),
    cidrsubnet(var.vpc_cidr, 3, 2)
  ]

  private_subnets = [
    cidrsubnet(var.vpc_cidr, 3, 1),
    cidrsubnet(var.vpc_cidr, 3, 3)
  ]

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                 = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "Tier"                                            = "Private"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"                          = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
}
```

The primary CIDR defaults to `192.168.0.0/16` and is divided into public and private subnets across two Availability Zones.

Public subnets host internet-facing Application Load Balancers, while private subnets host Amazon EKS worker nodes.

Subnet tags enable automatic discovery by Amazon EKS and the AWS Load Balancer Controller.

A NAT Gateway is deployed in each Availability Zone to provide outbound connectivity for workloads running in private subnets.

To reduce provisioning race conditions, Terraform pauses briefly before creating dependent resources.

```terraform
resource "time_sleep" "sleep-after-vpc-creation" {
  depends_on = [module.vpc]

  create_duration = "3m"
}
```

---

#### 4.5.2 Secondary VPC CIDR

A secondary CIDR (`100.64.0.0/16`) is associated with the VPC to isolate 5G interface addressing from Kubernetes networking.

```terraform
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = module.vpc.vpc_id
  cidr_block = "100.64.0.0/16"
}
```

This address space is reserved exclusively for Multus-attached interfaces.

---

#### 4.5.3 Multus Network Subnets

The `multus.tf` configuration allocates dedicated `/28` subnets from the secondary CIDR for each 5G interface.

Example:

```terraform
resource "aws_subnet" "amf-N2-subnet" {

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.secondary_cidr
  ]

  vpc_id            = aws_vpc_ipv4_cidr_block_association.secondary_cidr.vpc_id
  cidr_block        = "100.64.1.0/28"
  availability_zone = "eu-central-1c"

  tags = {
    Name = "amf-N2-subnet"
  }
}
```

Additional subnets are allocated for:

- AMF N2
- SMF N4
- UPF N3
- UPF N4
- UPF N6
- UERANSIM gNB N2
- UERANSIM gNB N3

These subnets are later used by Multus to attach secondary interfaces to Kubernetes pods.

The Free5GC and UERANSIM Helm charts are intentionally aligned with this networking design, assigning deterministic IP addresses from these subnet ranges to each network function.

---

#### 4.5.4 N6 Routing Configuration

The UPF N6 interface provides user-plane connectivity toward external networks.

A dedicated route table forwards outbound traffic from the UPF N6 subnet through the VPC NAT Gateway. The configuration uses the first NAT gateway ID from the VPC module (`natgw_ids[0]`); N6 egress is therefore tied to that Availability Zone rather than load-balanced across both NAT Gateways.

```terraform
resource "aws_route_table" "n6-route-table" {

  vpc_id = module.vpc.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = module.vpc.natgw_ids[0]
  }

  tags = {
    Name = "n6-route-table"
  }
}

resource "aws_route_table_association" "n6-rt-subnet-association" {

  subnet_id      = aws_subnet.free5gc-upf-N6-subnet.id
  route_table_id = aws_route_table.n6-route-table.id
}
```

Without this routing configuration, the UPF cannot provide internet connectivity through the N6 interface.

---

### 4.6 Provisioning Outcome

After this stage completes successfully, the platform environment contains:

- A VPC with primary and secondary IPv4 CIDRs
- Public subnets for internet-facing load balancers
- Private subnets for Amazon EKS worker nodes
- One NAT Gateway per Availability Zone
- Dedicated `/28` Multus subnets for 5G interfaces
- An N6 route table associated with the UPF N6 subnet
- Networking ready for Amazon EKS, Multus, and platform bootstrap

---

### 4.7 Troubleshooting

| Symptom | Possible Cause | Investigation |
|----------|----------------|---------------|
| Secondary CIDR association fails | CIDR already exists in the AWS account or Region | `aws_vpc_ipv4_cidr_block_association.secondary_cidr` |
| Pods receive no Multus IP address | Worker node and subnet are deployed in different Availability Zones | Compare `multus.tf` subnet AZs with the Amazon EKS node groups |
| UPF cannot reach the internet | Missing N6 route or NAT Gateway configuration | Verify the N6 route table and NAT Gateway |
| Application Load Balancer is not created | Missing subnet discovery tags | Review `public_subnet_tags` in `vpc.tf` |

---

### 4.8 Dependencies

The VPC provides the networking foundation for subsequent platform components.

- **Amazon EKS** deploys worker nodes into the private subnets.
- **Elastic Network Interfaces (ENIs)** are attached to worker nodes from the Multus subnets.
- **Platform Bootstrap** installs Multus CNI and Whereabouts IPAM.
- **Free5GC** and **UERANSIM** receive deterministic secondary IP addresses from the Multus subnet ranges.
- **Network Deployment Agent** deploys network functions that rely on this networking model.

---

## 5. Amazon EKS

### 5.1 Overview

This chapter describes the Amazon EKS cluster that hosts the platform environment.

The solution uses two Amazon EKS managed node groups to separate 5G control-plane and user-plane workloads while maintaining a fully managed Kubernetes environment.

After the worker nodes are provisioned, OpenTofu configures the Amazon VPC CNI, attaches dedicated secondary Elastic Network Interfaces (ENIs) from the VPC secondary CIDR, applies security groups, and brings those interfaces online using AWS Systems Manager (SSM).

These secondary interfaces are later consumed by Multus, enabling Free5GC and UERANSIM to expose deterministic 3GPP reference points (N2, N3, N4, and N6) independently of Kubernetes networking.

---

### 5.2 Architecture

<img width="5559" height="4600" alt="EKS Architecture" src="https://github.com/user-attachments/assets/c6a1b38f-58f5-4b7b-8eed-dbf6d1158d83" />

The Amazon EKS control plane is fully managed by AWS. Worker capacity is provided by two managed node groups deployed across separate Availability Zones.

This placement aligns with the Multus subnet design established in [§4 VPC](#4-vpc), allowing secondary interfaces to be attached within the same Availability Zone as their corresponding worker node.

#### 5.2.1 Managed Node Groups

| Node group | Role | Private subnet AZ | Kubernetes labels |
|------------|------|-------------------|-------------------|
| `5g-controlplane-node` | Free5GC control-plane network functions | `eu-central-1c` | `controlplane=true` |
| `5g-userplane-node` | UPF and UERANSIM | `eu-central-1b` | `userplane=true` |

#### 5.2.2 Secondary ENIs

| Worker node | ENI | Private IP | Device index | Reference point |
|-------------|-----|------------|--------------|-----------------|
| `5g-controlplane-node` | `amf-N2-eni` | `100.64.1.9` | 1 | AMF N2 |
| `5g-controlplane-node` | `smf-N4-eni` | `100.64.4.9` | 2 | SMF N4 |
| `5g-userplane-node` | `gnb-N2-eni` | `100.64.0.9` | 1 | UERANSIM gNB N2 |
| `5g-userplane-node` | `gnb-N3-eni` | `100.64.2.9` | 2 | UERANSIM gNB N3 |
| `5g-userplane-node` | `upf-N3-eni` | `100.64.3.9` | 3 | UPF N3 |
| `5g-userplane-node` | `upf-N4-eni` | `100.64.5.9` | 4 | UPF N4 |
| `5g-userplane-node` | `upf-N6-eni` | `100.64.6.9` | 5 | UPF N6 |

The secondary ENIs originate from the dedicated Multus subnets created during VPC provisioning and provide deterministic addressing for all 5G network functions.

---

### 5.3 Key Components

| Component | Responsibility |
|-----------|----------------|
| Amazon EKS Cluster | Managed Kubernetes control plane |
| Managed Node Groups | Dedicated control-plane and user-plane workers |
| Amazon VPC CNI | Provides primary pod networking and is configured for Multus compatibility |
| Secondary ENIs | Dedicated interfaces for 5G networking |
| AWS Systems Manager | Brings attached interfaces online after provisioning |
| Security Groups | Control traffic between 5G reference points and cluster resources |

---

### 5.4 Provisioning Workflow

```text
tofu apply
      │
      ▼
Provision Amazon EKS
      │
      ▼
Create Managed Node Groups
      │
      ▼
Configure Amazon VPC CNI
      │
      ▼
Attach Secondary ENIs
      │
      ▼
Configure Worker Networking
      │
      ▼
Apply Security Configuration
      │
      ▼
Amazon EKS Ready
```

After the cluster and worker nodes become available, the platform configures the networking components required by Free5GC and UERANSIM before the platform bootstrap stage installs cluster add-ons.

Node groups wait for the post-VPC sleep so subnet and NAT resources settle before workers launch. Secondary ENI attachment waits for VPC CNI tuning to finish so warm ENIs do not consume device indexes needed by Multus interfaces.

Security groups are referenced when ENIs are created; OpenTofu resolves those dependencies even though the security group resources are declared later in `multus.tf`.

---

### 5.5 Solution Implementation

#### 5.5.1 Cluster

The cluster is created with the community `terraform-aws-modules/eks/aws` module.

```terraform
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.2"

  cluster_name = var.eks_cluster_name

  vpc_id     = module.vpc.vpc_id
  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1]
  ]

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_group_defaults = {
    disk_size                  = 30
    enable_bootstrap_user_data = true
  }

  eks_managed_node_groups = {
    # controlplane5g-ng and userplane5g-ng defined below
  }
}
```

The API endpoint is publicly reachable so operators and CI can authenticate with `kubectl`. Worker nodes remain in private subnets and reach the internet through the VPC NAT Gateways.

The EKS module also creates the cluster and node security groups used by the control plane and worker instances. Additional rules are applied in [§5.5.7 Security Group Rules](#557-security-group-rules).

---

#### 5.5.2 Managed Node Groups

Both node groups share a common worker configuration:

| Setting | Value |
|---------|-------|
| AMI | `var.ami_id` (Ubuntu EKS-optimized; default `ami-064c2479baf726e71`) |
| Disk | 30 GiB |
| SSM access | `AmazonSSMManagedInstanceCore` attached to the node IAM role |
| Scaling | `min_size = 1`, `max_size = 1`, `desired_size = 1` per group |

##### Control-plane node group

```terraform
controlplane5g-ng = {
  depends_on = [time_sleep.sleep-after-vpc-creation]
  name       = "5g-controlplane-node"
  subnet_ids = [module.vpc.private_subnets[1]]

  instance_types = ["m5.4xlarge"]
  ami_id         = var.ami_id

  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  post_bootstrap_user_data = <<EOF
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl wget apt-transport-https net-tools make git vim
sudo apt install -y binutils gcc libsctp-dev lksctp-tools
EOF

  labels = {
    controlplane = "true"
  }

  min_size     = 1
  max_size     = 1
  desired_size = 1
}
```

Bootstrap installs networking utilities and SCTP tooling required by control-plane network functions. The `controlplane=true` label is used by Free5GC Helm charts for pod placement.

##### User-plane node group

```terraform
userplane5g-ng = {
  depends_on = [time_sleep.sleep-after-vpc-creation]
  name       = "5g-userplane-node"
  subnet_ids = [module.vpc.private_subnets[0]]

  instance_types = ["c4.4xlarge"]
  ami_id         = var.ami_id

  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  post_bootstrap_user_data = <<EOF
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl wget apt-transport-https net-tools make git vim
sudo apt install -y binutils gcc libsctp-dev lksctp-tools
git clone -b v0.8.10 https://github.com/free5gc/gtp5g.git
cd gtp5g
make
sudo make install
EOF

  labels = {
    userplane = "true"
  }

  min_size     = 1
  max_size     = 1
  desired_size = 1
}
```

In addition to the shared tooling, this node builds and installs the Free5GC `gtp5g` kernel module so the UPF can terminate GTP-U traffic on the N3 interface.

---

#### 5.5.3 Amazon VPC CNI

Secondary ENIs from Multus subnets must attach cleanly to the workers. The platform sets `WARM_ENI_TARGET=0` on the `aws-node` DaemonSet so the VPC CNI does not pre-allocate warm ENIs that would compete with Multus attachments.

```terraform
resource "kubernetes_env" "vpc-cni" {
  depends_on = [module.eks]
  container  = "aws-node"

  metadata {
    name      = "aws-node"
    namespace = "kube-system"
  }

  api_version = "apps/v1"
  kind        = "DaemonSet"

  env {
    name  = "WARM_ENI_TARGET"
    value = "0"
  }

  force = true
}
```

A short sleep follows this change so the DaemonSet can roll out before secondary ENI attachments begin.

---

#### 5.5.4 Secondary ENI Attachments

After the node groups exist, `multus.tf` looks up each worker by Name tag and attaches secondary ENIs from the Multus subnets created during VPC provisioning.

Each ENI is tagged with `node.k8s.amazonaws.com/no_manage = true` so the VPC CNI does not manage or reclaim the interface.

##### Control-plane attachments

```terraform
data "aws_instance" "_5gcontrolplane-node" {
  depends_on = [module.eks.eks_managed_node_groups]

  filter {
    name   = "tag:Name"
    values = ["5g-controlplane-node"]
  }
}

resource "aws_network_interface" "amf-N2-eni" {
  subnet_id       = aws_subnet.amf-N2-subnet.id
  private_ips     = ["100.64.1.9"]
  security_groups = [aws_security_group.amf-N2-sg.id]

  tags = {
    Name                                 = "amf-N2-eni"
    "node.k8s.amazonaws.com/no_manage" = "true"
  }
}

resource "aws_network_interface_attachment" "amf-N2-eni-attachment" {
  depends_on           = [time_sleep.sleep-after-env-variable]
  instance_id          = data.aws_instance._5gcontrolplane-node.id
  network_interface_id = aws_network_interface.amf-N2-eni.id
  device_index         = 1
}
```

The control-plane worker then receives `smf-N4-eni` (`100.64.4.9`) at device index `2`. Short sleeps between attachments reduce race conditions while AWS attaches successive interfaces.

##### User-plane attachments

```terraform
data "aws_instance" "_5g-userplane-node" {
  depends_on = [module.eks.eks_managed_node_groups]

  filter {
    name   = "tag:Name"
    values = ["5g-userplane-node"]
  }
}

resource "aws_network_interface" "gnb-N2-eni" {
  subnet_id       = aws_subnet.ueransim-gnb-N2-subnet.id
  private_ips     = ["100.64.0.9"]
  security_groups = [aws_security_group.gnb-N2-sg.id]

  tags = {
    Name                                 = "gnb-N2-eni"
    "node.k8s.amazonaws.com/no_manage" = "true"
  }
}

resource "aws_network_interface_attachment" "gnb-N2-eni-attachment" {
  depends_on           = [time_sleep.sleep-after-env-variable]
  instance_id          = data.aws_instance._5g-userplane-node.id
  network_interface_id = aws_network_interface.gnb-N2-eni.id
  device_index         = 1
}
```

Additional user-plane ENIs are attached in order:

- `gnb-N3-eni` → `100.64.2.9` (device index `2`)
- `upf-N3-eni` → `100.64.3.9` (device index `3`)
- `upf-N4-eni` → `100.64.5.9` (device index `4`)
- `upf-N6-eni` → `100.64.6.9` (device index `5`)

---

#### 5.5.5 Interface Initialization (AWS Systems Manager)

Attaching an ENI in AWS does not automatically bring the Linux interface up. SSM documents in `ssm.tf` run on each worker after attachment completes.

```terraform
resource "aws_ssm_document" "ssm_doc_5gcp_node_eni_state_up" {
  depends_on      = [aws_network_interface_attachment.smf-N4-eni-attachment]
  name            = "ssm_doc_5gcp_node_eni_state_up"
  document_format = "YAML"
  document_type   = "Command"

  content = <<DOC
schemaVersion: '1.2'
description: Bring up the additional interfaces of the instance.
parameters: {}
runtimeConfig:
  'aws:runShellScript':
    properties:
      - id: '0.aws:runShellScript'
        runCommand:
          - ip link set ens6 up
          - ip link set ens6 mtu 9001
          - ip link set ens7 up
          - ip link set ens7 mtu 9001
DOC
}
```

| Worker node | SSM document | Interfaces brought up |
|-------------|--------------|----------------------|
| `5g-controlplane-node` | `ssm_doc_5gcp_node_eni_state_up` | `ens6`, `ens7` (AMF N2, SMF N4) |
| `5g-userplane-node` | `ssm_doc_5gup_node_eni_state_up` | `ens4`–`ens8` (gNB N2/N3, UPF N3/N4/N6) |

Associations target the worker Name tags so the commands run on the correct instances. Jumbo-frame MTU (`9001`) is applied where required.

---

#### 5.5.6 Security Groups

The platform uses security groups at three layers: EKS-managed groups for the cluster and nodes, dedicated Multus ENI groups for 5G reference points, and an Amazon EFS group for shared storage.

##### Amazon EKS Security Groups

Created by the EKS module and referenced from `eks.tf`:

| Security group | Managed by | Attached to | Purpose |
|----------------|------------|-------------|---------|
| Cluster primary security group | EKS module | EKS control plane | Default cluster-to-node communication |
| Node security group | EKS module | Worker instances | Default node ingress/egress; extended by custom rules |

##### Multus Security Groups

Defined in `multus.tf` and attached to secondary ENIs:

| Security group | ENI | Reference point | Description |
|----------------|-----|-----------------|-------------|
| `amf-N2-sg` | `amf-N2-eni` | AMF N2 | Allow ingress traffic from gNB |
| `smf-N4-sg` | `smf-N4-eni` | SMF N4 | Allow ingress traffic from UPF |
| `gnb-N2-sg` | `gnb-N2-eni` | UERANSIM gNB N2 | Allow ingress traffic from AMF |
| `gnb-N3-sg` | `gnb-N3-eni` | UERANSIM gNB N3 | Allow N3 ingress from UPF |
| `upf-N3-sg` | `upf-N3-eni` | UPF N3 | Allow ingress traffic from gNB |
| `upf-N4-sg` | `upf-N4-eni` | UPF N4 | Allow ingress traffic from SMF |
| `upf-N6-sg` | `upf-N6-eni` | UPF N6 | Allow N6 outbound traffic from UPF |

Example:

```terraform
resource "aws_security_group" "amf-N2-sg" {
  name        = "amf-N2-sg"
  description = "Allow ingress traffic from gNB"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "amf-N2-sg"
  }
}
```

##### Amazon EFS Security Group

Defined in `efs.tf` through the EFS module:

| Security group | Managed by | Purpose |
|----------------|------------|---------|
| EFS security group | `terraform-aws-modules/efs/aws` | NFS access for persistent volumes |

```terraform
security_group_rules = {
  ingress = {
    description = "NFS ingress from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress = {
    description = "allow all egress traffic"
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

---

#### 5.5.7 Security Group Rules

Custom rules extend the default EKS and Multus security groups.

##### Amazon EKS Rules

Defined in `eks.tf` on the EKS node security group:

| Rule | Type | Protocol | Ports | Source | Purpose |
|------|------|----------|-------|--------|---------|
| `allow_sidecar_injection_SG_rule` | Ingress | TCP | `15017` | Cluster primary security group | Istio sidecar-injection webhook |
| `allow_http_traffic_between_nodes_SG_rule` | Ingress | TCP | `80` | Node security group (self) | HTTP between control-plane and user-plane workers |

```terraform
resource "aws_security_group_rule" "allow_sidecar_injection_SG_rule" {
  depends_on = [module.eks]

  description              = "Webhook container port, From Control Plane"
  protocol                 = "tcp"
  type                     = "ingress"
  from_port                = 15017
  to_port                  = 15017
  security_group_id        = module.eks.node_security_group_id
  source_security_group_id = module.eks.cluster_primary_security_group_id
}
```

##### Multus Rules

Defined in `multus.tf`. All peer rules use protocol `-1` (all traffic) unless noted.

**N2 — gNB ↔ AMF**

| Rule | Direction | Security group | Peer |
|------|-----------|----------------|------|
| `allow-egress-from-gnb-to-amf` | Egress | `gnb-N2-sg` | `amf-N2-sg` |
| `allow-ingress-to-amf-from-gnb` | Ingress | `amf-N2-sg` | `gnb-N2-sg` |
| `allow-egress-from-amf-to-gnb` | Egress | `amf-N2-sg` | `gnb-N2-sg` |
| `allow-ingress-to-gnb-from-amf` | Ingress | `gnb-N2-sg` | `amf-N2-sg` |

**N3 — gNB ↔ UPF**

| Rule | Direction | Security group | Peer |
|------|-----------|----------------|------|
| `allow-egress-from-gnb-to-upf` | Egress | `gnb-N3-sg` | `upf-N3-sg` |
| `allow-ingress-to-upf-from-gnb` | Ingress | `upf-N3-sg` | `gnb-N3-sg` |
| `allow-egress-from-upf-to-gnb` | Egress | `upf-N3-sg` | `gnb-N3-sg` |
| `allow-ingress-to-gnb-from-upf` | Ingress | `gnb-N3-sg` | `upf-N3-sg` |

**N4 — SMF ↔ UPF**

| Rule | Direction | Security group | Peer |
|------|-----------|----------------|------|
| `allow-egress-from-smf-to-upf` | Egress | `smf-N4-sg` | `upf-N4-sg` |
| `allow-ingress-to-upf-from-smf` | Ingress | `upf-N4-sg` | `smf-N4-sg` |
| `allow-egress-from-upf-to-smf` | Egress | `upf-N4-sg` | `smf-N4-sg` |
| `allow-ingress-to-smf-from-upf` | Ingress | `smf-N4-sg` | `upf-N4-sg` |

**N6 — UPF → data network**

| Rule | Direction | Security group | Destination |
|------|-----------|----------------|-------------|
| `allow-egress-from-upf-to-DN` | Egress | `upf-N6-sg` | `0.0.0.0/0` |

Example peer rule:

```terraform
resource "aws_security_group_rule" "allow-ingress-to-amf-from-gnb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.amf-N2-sg.id
  source_security_group_id = aws_security_group.gnb-N2-sg.id
}
```

---

### 5.6 Provisioning Outcome

After this stage completes successfully, the platform environment contains:

- An Amazon EKS cluster with a publicly accessible API endpoint
- Two managed node groups dedicated to control-plane and user-plane workloads
- Amazon VPC CNI configured for Multus compatibility
- Secondary ENIs attached with deterministic IP addresses
- AWS Systems Manager automation for interface initialization
- Security groups protecting cluster and 5G network traffic
- A Kubernetes platform ready for cluster bootstrap and network-function deployment

---

### 5.7 Troubleshooting

| Symptom | Possible Cause | Investigation |
|----------|----------------|---------------|
| Node group creation fails | VPC resources unavailable | Verify VPC provisioning completed successfully |
| Pods scheduled on the wrong worker | Missing Kubernetes labels | Verify node labels and Helm scheduling rules |
| Secondary ENI attachment fails | Availability Zone mismatch or VPC CNI configuration | Verify subnet placement and `WARM_ENI_TARGET` |
| Secondary interface remains down | AWS Systems Manager automation failed | Review SSM command history |
| Incorrect 5G interface IP | ENI or Helm configuration mismatch | Compare ENI configuration with Helm values |
| N2, N3, or N4 connectivity fails | Missing security group rules | Verify peer security group configuration |
| UPF cannot access external networks | Missing N6 routing or security rules | Verify N6 route table and security group |
| `gtp5g` module unavailable | User-plane bootstrap failed | Inspect bootstrap logs |
| Istio sidecar injection fails | Missing webhook rule | Verify EKS node security group rules |
| EFS mount fails | NFS access blocked | Verify Amazon EFS security group configuration |

---

### 5.8 Dependencies

The Amazon EKS platform provides the execution environment for subsequent infrastructure components.

- **IAM** configures IRSA and cluster identity.
- **Amazon EFS** provides persistent shared storage.
- **Platform Bootstrap** installs Argo CD, Multus, Whereabouts, Istio, and supporting platform services.
- **Free5GC** deploys control-plane network functions to the control-plane node group.
- **UERANSIM** and the **UPF** deploy to the user-plane node group using the attached secondary ENIs.
- **Network Deployment Agent** orchestrates deployment and lifecycle management of the network functions.

---

## 6. Platform Infrastructure

Infrastructure provisioned directly by OpenTofu before Kubernetes platform bootstrap.

### 6.1 Overview

After the VPC and EKS foundations exist, OpenTofu provisions shared platform services required by bootstrap and day-2 operations: identity (IRSA), shared storage (EFS), public TLS (ACM + Cloudflare), and the GitOps control plane (Argo CD plus repository registration).

### 6.2 Architecture

```text
EKS Ready
   │
   ├── IAM / IRSA roles (ALB, EFS CSI, Network Deployment Agent → Bedrock)
   ├── Amazon EFS (MongoDB and other PVCs)
   ├── ACM certificate + Cloudflare DNS validation
   └── Argo CD Helm release + Git repo secret + cluster-bootstrap Application
```

### 6.3 Key Components

| Component | Responsibility |
|-----------|----------------|
| Providers & S3 backend | AWS, Kubernetes, Helm, Cloudflare; remote state |
| Configuration model | `variables.tf` + local `vars.auto.tfvars` |
| IAM & IRSA | Workload identity to AWS APIs |
| Amazon EFS | NFS-backed persistent volumes |
| TLS & DNS | Public certificates and hostname automation |
| Argo CD | GitOps engine and app-of-apps entrypoint |
| Git repository integration | Register platform Git URL (optional credentials) |

### 6.4 Provisioning Workflow

```text
EKS Ready
   │
   ▼
IAM (IRSA)
   │
   ▼
EFS
   │
   ▼
ACM + Cloudflare validation
   │
   ▼
Argo CD Helm release
   │
   ▼
Git repo secret + cluster-bootstrap Application
   │
   ▼
Infrastructure Layer Complete
```

### 6.5 Solution Implementation

#### 6.5.1 Terraform Providers & Backend

`infrastructure/providers.tf` configures OpenTofu providers and remote state.

```terraform
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws        = { source = "hashicorp/aws", version = "5.100.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "2.38.0" }
    helm       = { source = "hashicorp/helm", version = "3.0.2" }
    kubectl    = { source = "gavinbunney/kubectl", version = "1.19.0" }
    cloudflare = { source = "cloudflare/cloudflare", version = "5.7.1" }
  }

  backend "s3" {
    region = var.region
    bucket = var.bucket-name
    key    = var.key
  }
}
```

The AWS provider uses `var.region`. Kubernetes, Helm, and kubectl authenticate to the EKS API using `aws eks get-token`. Cloudflare uses `var.cloudflare_api_token` for ACM DNS validation and later external-dns credentials via envsubst.

---

#### 6.5.2 Configuration Model

Inputs are declared in `infrastructure/variables.tf`. Operators copy the empty template and supply environment values locally:

```bash
cp vars.auto.tfvars.example vars.auto.tfvars
```

| Variable | Purpose |
|----------|---------|
| `region` | AWS region (default `eu-central-1`) |
| `bucket-name`, `key` | S3 remote state |
| `vpc_name`, `vpc_cidr`, `azs` | VPC layout |
| `eks_cluster_name`, `ami_id` | EKS cluster and worker AMI |
| `domain_name`, `zone_id`, `cloudflare_api_token` | Public DNS and TLS validation |
| `bedrock_region`, `bedrock_model_id` | Agent inference settings |
| `git_repo_url`, `git_repo_password` | Argo CD repository registration (password optional for public repos) |

`cloudflare_api_token` is marked sensitive. The example file ships with empty values so the public repository never contains environment secrets.

---

#### 6.5.3 IAM & IRSA

`infrastructure/iam.tf` creates IAM roles trusted by the EKS OIDC provider for selected service accounts:

| Role | Service account | Purpose |
|------|-----------------|---------|
| `aws_load_balancer_controller_role` | `kube-system/aws-load-balancer-controller` | Provision ALBs |
| `aws_efs_csi_driver_role` | EFS CSI controller/node SAs | Manage EFS mounts |
| `network_deployment_agent_bedrock_role` | `network-deployment-agent/network-deployment-agent` | `bedrock:InvokeModel` / streaming |

Example trust condition for the load balancer controller:

```terraform
condition {
  test     = "StringEquals"
  variable = "${module.eks.oidc_provider}:sub"
  values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
}
```

The Bedrock role allows invoke on foundation models and inference profiles. Role ARNs are passed into the `cluster-bootstrap` Application as envsubst variables (`LBC_IAM_ROLE_ARN`, `EFS_ARN`, `NETWORK_DEPLOYMENT_AGENT_BEDROCK_ROLE_ARN`).

---

#### 6.5.4 Amazon EFS

`infrastructure/efs.tf` provisions a shared file system with a mount target in the control-plane private subnet AZ and a security group allowing NFS (TCP 2049) from the VPC CIDR.

```terraform
module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "1.8.0"

  name = "efs"
  mount_targets = {
    (module.vpc.azs[1]) = { subnet_id = module.vpc.private_subnets[1] }
  }
  attach_policy = false
  # security_group_rules: ingress 2049/tcp from VPC CIDR; egress allow all
}
```

The file system ID is injected into the GitOps `storage-class` Application so the `efs-sc` StorageClass references the correct `fileSystemId`. Runtime PVC usage is described in §10.

---

#### 6.5.5 TLS & DNS (ACM + Cloudflare)

`infrastructure/acm.tf` requests a regional ACM certificate for `var.domain_name` and `*.${var.domain_name}`, validated by DNS. Because the zone is on Cloudflare (not Route 53), OpenTofu creates the validation record directly:

```terraform
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.2.0"

  domain_name               = var.domain_name
  zone_id                   = var.zone_id
  create_route53_records    = false
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.domain_name}"]
}

resource "cloudflare_dns_record" "validation_record" {
  zone_id = var.zone_id
  ttl     = "1"
  name    = module.acm.acm_certificate_domain_validation_options[0].resource_record_name
  type    = module.acm.acm_certificate_domain_validation_options[0].resource_record_type
  content = module.acm.acm_certificate_domain_validation_options[0].resource_record_value
}
```

The certificate ARN is passed to Argo CD as `ACM_CERTIFICATE_ARN` and patched onto the ALB Ingress annotation during bootstrap.

---

#### 6.5.6 Argo CD Install

`infrastructure/argocd.tf` installs Argo CD via Helm (`argo-cd` chart) into the `argocd` namespace and configures an **envsubst** Config Management Plugin so Application manifests can receive OpenTofu-produced values at sync time.

It then creates the parent Application `cluster-bootstrap`:

```yaml
source:
  repoURL: https://github.com/5gcloudlabs/5g-platform-aws.git
  targetRevision: main
  path: cluster-bootstrap/argocd-apps/required-apps
  plugin:
    name: envsubst
    env:
      - name: REGION
        value: ${var.region}
      - name: DOMAIN_NAME
        value: ${var.domain_name}
      # … ACM ARN, EFS ID, IRSA ARNs, Bedrock settings …
```

Automated sync with prune and self-heal is enabled. Only Argo CD and this Application are created by OpenTofu; child platform services come from Git (§7).

---

#### 6.5.7 Git Repository Integration

`infrastructure/k8s_git-repo-secret.tf` registers the platform Git repository with Argo CD:

```terraform
resource "kubernetes_secret_v1" "git-repo-secret" {
  metadata {
    name      = "git-repo-secret"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = merge(
    { type = "git", url = var.git_repo_url },
    var.git_repo_password != "" ? {
      username = var.git_repo_username
      password = var.git_repo_password
    } : {}
  )
}
```

When `git_repo_password` is empty (public repository), no credentials are stored.

### 6.6 Provisioning Outcome

- IRSA roles available to ALB controller, EFS CSI, and the Network Deployment Agent  
- EFS file system and mount target ready for the `efs-sc` StorageClass  
- ACM certificate issued for the platform domain  
- Argo CD running with envsubst CMP  
- `cluster-bootstrap` Application created and syncing  
- Git repository registered for GitOps  

### 6.7 Troubleshooting

| Symptom | Possible Cause | Investigation |
|---------|----------------|---------------|
| Argo CD apps stuck | Repo URL or credentials | Check `git-repo-secret` and Application source |
| Certificate pending | DNS validation failure | Cloudflare token, zone ID, ACM validation record |
| EFS mount fails | SG or mount target AZ | EFS SG allows 2049 from VPC CIDR |
| IRSA access denied | Wrong SA annotation or role ARN | Compare Helm SA annotation to `iam.tf` role |

### 6.8 Dependencies

Feeds **§7 Platform Bootstrap**. Depends on **§4 VPC** and **§5 Amazon EKS**.

---

# Part III — Kubernetes Platform Layer

## 7. Platform Bootstrap

### 7.1 Overview

Argo CD synchronizes required platform services from `cluster-bootstrap/` using an app-of-apps pattern. Only Argo CD itself is installed by OpenTofu; everything else in this layer is GitOps-managed.

### 7.2 Architecture

```text
Application: cluster-bootstrap  (created by OpenTofu)
        │
        ▼
path: cluster-bootstrap/argocd-apps/required-apps/
        │
        ├── multus / whereabouts
        ├── aws-load-balancer-controller / aws-efs-csi-driver / storage-class
        ├── cert-manager / external-dns / cloudflare-token-secret
        ├── istio-base / istiod / istio-gateway / ingress / gateway / virtual-services
        ├── kube-prometheus-stack / loki
        ├── argo-workflows
        └── network-deployment-agent
```

Manifests use `${ARGOCD_ENV_*}` placeholders. The envsubst CMP substitutes values injected by the parent Application (domain, ACM ARN, IRSA ARNs, EFS ID, Bedrock settings).

### 7.3 Key Components

| Application area | Examples |
|------------------|----------|
| CNI extensions | Multus, Whereabouts |
| Ingress / mesh | AWS LBC, Istio, gateway, virtual-services, Ingress |
| Certificates / DNS | cert-manager, external-dns, Cloudflare token secret |
| Storage | EFS CSI, `efs-sc` StorageClass |
| Observability | kube-prometheus-stack, Loki |
| Operations | Argo Workflows, Network Deployment Agent |

Network components under `5g/` are **not** part of bootstrap.

### 7.4 Bootstrap Workflow

```text
Argo CD Ready
   │
   ▼
Sync cluster-bootstrap (app-of-apps)
   │
   ▼
Sync required-apps (envsubst applied)
   │
   ▼
Platform services Ready
   │
   ▼
https://console.<domain> available
```

### 7.5 Solution Implementation

#### 7.5.1 App-of-Apps Pattern

The parent Application points at a directory of child Application manifests. Each child declares its own `source.path` (Helm chart or Kustomize resources) and destination namespace. Automated sync keeps the cluster aligned with Git on `main`.

#### 7.5.2 Argo CD Applications

Child Applications live under `cluster-bootstrap/argocd-apps/required-apps/`. Examples:

| File | Deploys |
|------|---------|
| `multus-chart.yml` / `whereabouts-chart.yml` | Multus CNI, Whereabouts IPAM |
| `aws-lbc-chart.yml` | AWS Load Balancer Controller |
| `aws-efs-csi-driver-chart.yml` / `storage-class.yml` | EFS CSI and `efs-sc` |
| `istio-charts.yml` / `istio-resources.yml` | Istio control plane and gateway resources |
| `ingress.yml` | ALB Ingress hosts (`console`, `argocd`, `grafana`, …) |
| `network-deployment-agent-charts.yml` | Agent UI + backend |
| `argo-workflows.yml` | Workflow engine for multi-step 5G deploys |

#### 7.5.3 Helm Charts

Charts and supporting manifests live under `cluster-bootstrap/helm-charts/` and `cluster-bootstrap/k8s-resources/`. Platform-specific values (IAM role ARNs, EFS ID, domain) are applied via envsubst / Kustomize patches rather than hardcoding account-specific data in Git.

#### 7.5.4 Deployment Ordering

Ordering uses Argo CD hooks and natural dependencies (for example CSI before workloads that need PVs; cert-manager and external-dns before TLS hostnames are relied upon; Istio before Ingress/VirtualServices). The Ingress Application uses a `PostSync` hook so hosts are patched after dependent services exist.

### 7.6 Bootstrap Outcome

- Multus and Whereabouts ready for secondary interfaces  
- ALB controller and Istio able to publish HTTPS endpoints  
- Observability stack running  
- Argo Workflows available  
- Network Deployment Agent reachable at `console.<domain>`  

### 7.7 Troubleshooting

| Symptom | Possible Cause | Investigation |
|---------|----------------|---------------|
| App OutOfSync / CompareError | envsubst / wrong env | Parent Application env; CMP logs on repo-server |
| Agent UI unreachable | Ingress / DNS / cert | §9; Cloudflare records; ACM ARN annotation |
| EFS PVC pending | StorageClass fileSystemId | `storage-class` Application patch vs `EFS_ID` |

### 7.8 Dependencies

Depends on §6. Enables §8–§12.

---

## 8. Kubernetes Networking

### 8.1 Overview

Multus and Whereabouts attach secondary interfaces to pods so Free5GC and UERANSIM can use the fixed reference-point addresses prepared in §4–§5. The primary VPC CNI continues to provide standard pod networking on the primary CIDR.

### 8.2 Architecture

```text
Pod network (primary)     5G reference-point network (secondary)
─────────────────────     ──────────────────────────────────────
VPC CNI / 192.168.0.0/16  Multus → host ENI (ens*) / 100.64.0.0/16
                          Whereabouts or static range in NAD
                          ipvlan or host-device per interface
```

See also [CNI overview](./e.%20CNI-1.md) and [interface detail](./f.%20CNI-2.md).

### 8.3 Key Components

| Component | Responsibility |
|-----------|----------------|
| Multus CNI | Invokes additional CNI configs per pod annotation |
| Whereabouts | Cluster-wide IPAM for Multus ranges when used |
| NetworkAttachmentDefinition (NAD) | Per-reference-point CNI config (master interface, subnet, IP) |
| Helm values | Enable NADs and set `masterIf`, subnet, and NF IP |

### 8.4 Runtime Workflow

```text
Pod scheduled (nodeSelector: controlplane/userplane)
   │
   ▼
Multus reads k8s.v1.cni.cncf.io/networks annotations
   │
   ▼
Loads NAD (e.g. n2networkamf) → attaches via masterIf (ens6, …)
   │
   ▼
NF process binds to configured reference-point address
```

### 8.5 Solution Implementation

#### 8.5.1 Multus CNI

Installed by the `multus` Argo CD Application from `cluster-bootstrap/helm-charts/multus` into `kube-system`. Multus runs as a DaemonSet (thick plugin pattern) so every worker can attach secondary interfaces.

#### 8.5.2 Whereabouts IPAM

Installed alongside Multus (`whereabouts-chart.yml`). NAD IPAM sections can use the `whereabouts` type with an explicit range; Free5GC charts pin `range_start` / `range_end` to the same static address for deterministic NF endpoints.

#### 8.5.3 NetworkAttachmentDefinitions

NADs are rendered by Free5GC / UERANSIM Helm charts (for example `amf-n2-nad.yaml`, `upf-n3-nad.yaml`). Example pattern for AMF N2:

- `type`: `ipvlan` (or `host-device` for selected UPF interfaces)  
- `master` / `device`: host interface from SSM bring-up (`ens6`, `ens7`, …)  
- IPAM range aligned to Multus subnet (`100.64.1.0/28`) with a single allowed address for the NF  

#### 8.5.4 Network Interface Allocation

Host ENIs are attached and brought up in §5. Pod interfaces reuse those masters:

| NF interface | masterIf (typical) | Pod IP (Helm) |
|--------------|--------------------|---------------|
| AMF N2 | `ens6` on control-plane node | `100.64.1.10` |
| SMF N4 | `ens7` on control-plane node | `100.64.4.10` |
| UPF N3 | `ens6` on user-plane node | `100.64.3.10` |
| UPF N4 | `ens7` on user-plane node | `100.64.5.10` |
| UPF N6 | `ens8` on user-plane node | `100.64.6.10` |

ENI primary addresses (for example `100.64.1.9`) remain on the host; pod addresses use adjacent IPs in the same `/28` as defined in Helm.

#### 8.5.5 Helm Integration

`5g/helm-charts/free5gc/values.yaml` sets `global.n2networkAMF`, `n4networkSMF`, `n3networkUPF`, `n4networkUPF`, and `n6network` with `enabled`, `masterIf`, subnet, gateway, and `ipAddress`. UERANSIM charts similarly bind gNB N2/N3 to their Multus masters. Changing an IP requires coordinated updates to Helm values, and optionally ENI `private_ips` / routes if the subnet design changes.

### 8.6 Runtime Outcome

Pods on control-plane and user-plane nodes present the expected secondary interfaces and IPs; N2/N3/N4/N6 traffic flows on the secondary CIDR independent of the primary pod network.

### 8.7 Troubleshooting

| Symptom | Possible Cause | Investigation |
|---------|----------------|---------------|
| No Multus IP | AZ mismatch / interface down / NAD misconfig | §4–§5; `ip link` on node; NAD YAML |
| Wrong IP | Helm vs design drift | Compare chart values to §14 |
| GTP-U failure | `gtp5g` or N3 host-device | §5.5.2; UPF logs |

### 8.8 Dependencies

Depends on §5 ENIs/SSM and §7 Multus install. Enables §11.

---

## 9. Ingress & External Access

### 9.1 Overview

Public HTTPS access to the Network Deployment Agent and other published services uses the AWS Load Balancer Controller, Istio, cert-manager, and external-dns, with an ACM certificate prepared in §6.

### 9.2 Architecture

```text
Internet
   │
   ▼
Application Load Balancer  (ACM cert on HTTPS listener)
   │
   ▼
Istio Ingress Gateway
   │
   ▼
VirtualServices / Ingress rules
   ├── console.<domain>      → Network Deployment Agent
   ├── argocd.<domain>       → Argo CD UI
   ├── grafana.<domain>      → Grafana
   ├── prometheus.<domain>   → Prometheus
   └── free5gc.<domain>      → Free5GC WebUI (when deployed)
```

See [Ingress diagram](./g.%20Ingress.md).

### 9.3 Key Components

| Component | Responsibility |
|-----------|----------------|
| AWS Load Balancer Controller | Translates Ingress to ALB |
| Istio Gateway | L7 entry inside the mesh |
| VirtualServices / Ingress | Host-based routing |
| external-dns | Creates Cloudflare records for hosts |
| cert-manager | Cluster certificate automation (where used) |
| ACM certificate | TLS on the ALB (ARN from OpenTofu) |

### 9.4 Traffic Flow

1. Client resolves `console.<domain>` via Cloudflare (external-dns).  
2. TLS terminates on the ALB using the ACM certificate ARN annotated on the Ingress.  
3. ALB forwards to the Istio ingress gateway NodePort/target group.  
4. Gateway / VirtualService routes by hostname to the backend Service.  

### 9.5 Solution Implementation

#### 9.5.1 AWS Load Balancer Controller

Deployed from `aws-lbc-chart.yml` with IRSA (`LBC_IAM_ROLE_ARN`). Requires public subnet tags from §4 (`kubernetes.io/role/elb=1`).

#### 9.5.2 Istio Gateway

`istio-charts.yml` / `istio-resources.yml` install Istio and gateway resources in `istio-system`. Node security group rule on port `15017` (§5.5.7) allows control-plane webhook injection.

#### 9.5.3 Virtual Services

Host routing for platform UIs is coordinated with the shared Ingress object. The `ingress` Application Kustomize-patches hosts using `DOMAIN_NAME`.

#### 9.5.4 External DNS

`external-dns-chart.yml` plus `cloudflare-token-secret.yml` publish DNS records into the Cloudflare zone using the token supplied via envsubst (`CF_API_TOKEN`).

#### 9.5.5 Certificate Management

Platform edge TLS for the ALB uses the ACM certificate from §6.5.5 (`alb.ingress.kubernetes.io/certificate-arn`). cert-manager Applications support additional in-cluster certificate workflows as needed by mesh or internal services.

Example Ingress host patching (`ingress.yml`):

```yaml
- op: replace
  path: /spec/rules/1/host
  value: "console.${ARGOCD_ENV_DOMAIN_NAME}"
```

### 9.6 Deployment Outcome

`console.<domain>`, `argocd.<domain>`, and observability hostnames resolve and serve HTTPS through the ALB.

### 9.7 Troubleshooting

| Symptom | Possible Cause | Investigation |
|---------|----------------|---------------|
| No ALB | Subnet tags / LBC IAM | §4 `public_subnet_tags`; controller logs / IRSA |
| DNS missing | external-dns / Cloudflare token | Token secret; external-dns logs |
| TLS errors | Wrong/missing ACM ARN | Ingress annotation vs `ACM_CERTIFICATE_ARN` |

### 9.8 Dependencies

Depends on §6 ACM/DNS/IRSA and §7 ingress-related apps.

---

## 10. Observability & Storage

### 10.1 Overview

The laboratory includes metrics, dashboards, and log aggregation, plus EFS-backed persistent volumes for stateful components such as MongoDB used by Free5GC.

### 10.2 Architecture

```text
Workloads → ServiceMonitors / scrape configs → Prometheus → Grafana
Pods / apps → log pipeline → Loki → Grafana Explore

StatefulSet PVC → StorageClass efs-sc → EFS CSI → Amazon EFS (§6.5.4)
```

### 10.3 Key Components

| Component | Responsibility |
|-----------|----------------|
| kube-prometheus-stack | Prometheus, Alertmanager, Grafana |
| Loki stack | Log aggregation |
| EFS CSI driver | Mount EFS volumes into pods |
| StorageClass `efs-sc` | Dynamic / configured PVs on the platform file system |
| MongoDB (Free5GC) | Subscriber / config data on PVC |

### 10.4 Runtime Workflow

1. Bootstrap installs Prometheus, Grafana, and Loki Applications.  
2. `storage-class` Application sets `efs-sc` `fileSystemId` to `${ARGOCD_ENV_EFS_ID}`.  
3. When Free5GC deploys with `deployMongoDb: true`, MongoDB claims storage via `efs-sc`.  
4. Operators access Grafana at `grafana.<domain>` (§9).  

### 10.5 Solution Implementation

#### 10.5.1 Prometheus

Provided by `kube-prometheus-stack.yml`. Scrapes cluster and workload metrics; UI exposed via ingress hostname `prometheus.<domain>`.

#### 10.5.2 Grafana

Bundled with the Prometheus stack; dashboards for cluster health and (where configured) application metrics. Host: `grafana.<domain>`.

#### 10.5.3 Loki

`loki-stack.yml` aggregates logs for troubleshooting NF and platform pods.

#### 10.5.4 Persistent Volumes on EFS

```yaml
# storage-class Application patches efs-sc:
- op: replace
  path: /parameters/fileSystemId
  value: ${ARGOCD_ENV_EFS_ID}
```

Provisioning of the file system remains §6.5.4; this section covers the Kubernetes consumption path only.

#### 10.5.5 MongoDB Storage

Free5GC umbrella values enable MongoDB (`deployMongoDb: true`). The database uses a PVC on `efs-sc` so subscriber and NRF-related data survive pod restarts on the control-plane node.

### 10.6 Runtime Outcome

Dashboards and logs available; stateful NFs retain data across restarts using EFS.

### 10.7 Troubleshooting

| Symptom | Possible Cause | Investigation |
|---------|----------------|---------------|
| PVC pending | StorageClass / CSI / EFS SG | CSI pods; §6 EFS SG; `fileSystemId` |
| Grafana empty | Ingress or datasource | Host routing §9; Prometheus target health |

### 10.8 Dependencies

Depends on §6 EFS and §7 observability/storage apps. Used by §11 Free5GC.

---

# Part IV — 5G Network Layer

## 11. 5G Network Components

### 11.1 Overview

Free5GC, UERANSIM, and subscriber provisioning are deployed **on demand** in Phase 2 via the Network Deployment Agent, Argo CD Applications, and Argo Workflows — not during `tofu apply`.

### 11.2 Architecture

Control-plane NFs (AMF, SMF, NRF, UDM, …) schedule to `controlplane=true` nodes. UPF and UERANSIM schedule to `userplane=true` nodes and consume Multus interfaces for N2/N3/N4/N6.

See [5G Core](./a.%205G-Core.md) and [5G on EKS](./d.%205G-on-EKS.md).

### 11.3 Key Components

#### 11.3.1 Free5GC Core

NRF, UDM, UDR, AUSF, PCF, NSSF, AMF, SMF, UPF, WebUI, and MongoDB. UPF requires the `gtp5g` module on the user-plane worker ([§5.5.2](#552-managed-node-groups)).

#### 11.3.2 UERANSIM

Simulated gNB and UE for registration and PDU session testing over N2/N3 toward AMF/UPF.

#### 11.3.3 Subscriber Provisioning

Kubernetes Jobs / workflows that insert subscriber records (IMSI count, MCC/MNC) into the Free5GC data path for lab scenarios.

#### 11.3.4 Node Placement & Host Prerequisites

| Workload | Node label | Host prerequisites (see §5.5.2) |
|----------|------------|----------------------------------|
| Free5GC control-plane NFs | `controlplane=true` | SCTP tooling and networking utilities |
| UPF, UERANSIM | `userplane=true` | SCTP tooling + **`gtp5g` v0.8.10** |

### 11.4 Deployment Workflow

```text
Agent / catalog selection (MCC, MNC, count)
   │
   ▼
Single-step: kubectl apply Argo CD Application
   or
Multi-step: submit Argo Workflow
   │
   ▼
Helm release (Free5GC → subscribers → UERANSIM)
   │
   ▼
Registration · PDU session · N3/N6 user-plane path
```

### 11.5 Solution Implementation

#### 11.5.1 Deployment Catalog

`5g/deployment-catalog.yaml` is the single source of truth for deployable options consumed by the agent:

| Option ID | Type | Description |
|-----------|------|-------------|
| `free5gc` | kubectl | Deploy 5G core only |
| `sub-prov` | kubectl | Provision subscribers only |
| `ueransim` | kubectl | Deploy RAN/UE simulation only |
| `5gcore-sub-prov` | argo | Core + subscribers |
| `sub-prov-ueransim` | argo | Subscribers + UERANSIM (core already up) |
| `5g-solution` | argo | Full path: core → subscribers → UERANSIM |

Each entry references a manifest path under `5g/argocd-apps/` or `5g/argo-workflows/` and declares required parameters (`mcc`, `mnc`, `count`).

#### 11.5.2 Free5GC Helm Charts

Charts under `5g/helm-charts/free5gc/` (umbrella + NF subcharts). Global Multus settings align to §14 (for example AMF N2 `100.64.1.10` on `ens6`). Node selectors place CP NFs and UPF on the correct workers.

#### 11.5.3 UERANSIM Helm Charts

Charts under `5g/helm-charts/ueransim/` configure gNB N2/N3 toward AMF/UPF Multus addresses and schedule onto the user-plane node.

#### 11.5.4 Subscriber Provisioning

The `sub-prov` Application / workflow jobs create the requested number of subscribers for the given MCC/MNC so UERANSIM UEs can register.

#### 11.5.5 Argo CD Applications

| Path | Role |
|------|------|
| `5g/argocd-apps/free5gc-app/` | Free5GC Application |
| `5g/argocd-apps/sub-prov-app/` | Subscriber provisioning Application |
| `5g/argocd-apps/ueransim-app/` | UERANSIM Application |

#### 11.5.6 Deployment Workflows

| Workflow | Steps |
|----------|-------|
| `5gcore-sub-prov-wf.yaml` | Free5GC → sub-prov |
| `sub-prov-ueransim-wf.yaml` | sub-prov → UERANSIM |
| `5g-solution-wf.yaml` | Free5GC → sub-prov → UERANSIM |

Workflows run in Argo Workflows (installed at bootstrap) and parameterize MCC/MNC/count from the agent.

### 11.6 Deployment Outcome

Core NFs registered with NRF; subscribers present; UE/gNB connected; user-plane path via N3/N6 verified for the selected scenario.

### 11.7 Troubleshooting

| Symptom | Possible Cause | Investigation |
|---------|----------------|---------------|
| UPF CrashLoop | Missing `gtp5g` | §5.5.2; node `lsmod` / logs |
| No N2/N3 | Multus / SG / IP mismatch | §8, §5.5.6–7, §14 |
| UE registration fail | Subscribers / PLMN | sub-prov job; AMF logs; MCC/MNC |

### 11.8 Dependencies

Depends on §5–§8 and §10 (MongoDB storage). Driven by §12.

---

# Part V — Operations Layer

## 12. AI Capabilities

### 12.1 Overview

The Network Deployment Agent provides a console-driven, catalog-aware interface for deploying and managing network components. Intent understanding uses Amazon Bedrock (Anthropic Claude Haiku 4.5). Application source is maintained in [`5gcloudlabs/network-deployment-agent`](https://github.com/5gcloudlabs/network-deployment-agent) and deployed onto this platform during bootstrap.

### 12.2 Architecture

```text
Browser → https://console.<domain>
              │
              ▼
     Network Deployment Agent (UI + FastAPI backend)
              │
              ├── Bedrock (IRSA) — intent → catalog option
              ├── Fetch manifests from GITHUB_RAW_BASE (public repo)
              └── kubectl apply Application  OR  submit Argo Workflow
```

### 12.3 Capability Model

Capabilities are declared in `5g/deployment-catalog.yaml` (§11.5.1). The agent loads the catalog at runtime and maps natural-language requests to exactly one option, then collects MCC/MNC/count only when required.

### 12.4 Operational Workflow

```text
User: "Deploy the full 5G solution with MCC 602, MNC 02, and 10 subscribers"
   │
   ▼
Bedrock selects option id: 5g-solution
   │
   ▼
Agent submits 5g/argo-workflows/5g-solution-wf.yaml with parameters
   │
   ▼
Workflow deploys Free5GC → subscribers → UERANSIM
   │
   ▼
Agent reports status / next actions
```

### 12.5 Solution Implementation

#### 12.5.1 Network Deployment Agent

Helm chart: `cluster-bootstrap/helm-charts/network-deployment-agent/`, installed by `network-deployment-agent-charts.yml`. Exposes the console Service consumed by the shared Ingress.

#### 12.5.2 Deployment Catalog

Catalog path is configured on the agent (`DEPLOYMENT_CATALOG_PATH` / raw Git base). Adding a new deployable means adding a catalog entry plus manifests under `5g/` — not changing agent code for every option.

#### 12.5.3 Bedrock Integration

OpenTofu variables `bedrock_region` (optional override) and `bedrock_model_id` (default global Claude Haiku 4.5 inference profile) are passed through envsubst into the agent chart. The pod ServiceAccount is annotated with `NETWORK_DEPLOYMENT_AGENT_BEDROCK_ROLE_ARN` for IRSA. No static AWS access keys are required in the agent.

#### 12.5.4 Argo CD Integration

Single-step catalog options apply Argo CD Application manifests from `5g/argocd-apps/*`. Argo CD then reconciles the Helm releases onto the cluster.

#### 12.5.5 Argo Workflows Integration

Multi-step catalog options submit Workflows from `5g/argo-workflows/`, enabling ordered Free5GC → subscriber → UERANSIM pipelines with parameters.

#### 12.5.6 Platform Integration

Hostname `console.<domain>` is patched in the Ingress Application. Domain, Bedrock, and IRSA values originate from OpenTofu → parent Application env → agent Helm values.

### 12.6 Operational Outcome

Operators deploy and iterate on network scenarios from the browser without re-running OpenTofu or manually editing Kubernetes YAML.

### 12.7 Troubleshooting

| Symptom | Possible Cause | Investigation |
|---------|----------------|---------------|
| Bedrock errors | Model access / IRSA / region | Bedrock FTU; IAM role; `BEDROCK_MODEL_ID` |
| Deploy failed | Workflow / Application error | Argo Workflows UI; Application sync status |
| Catalog option missing | Catalog fetch / path | Agent env `GITHUB_RAW_BASE`; catalog YAML on `main` |

### 12.8 Security & Identity

Bedrock access uses IRSA. Public platform manifests are fetched without a GitHub token. Cloudflare and other secrets remain in local OpenTofu variables / Kubernetes secrets created at bootstrap — not in the agent image.

### 12.9 Extending the Platform

1. Add Helm charts / Applications / Workflows under `5g/`.  
2. Register them in `deployment-catalog.yaml`.  
3. Change `infrastructure/` only when new cloud resources or IRSA permissions are required.  

---

## 13. End-to-End Lifecycle

### 13.0 Lifecycle Overview

```text
┌──────────────┐   ┌──────────────┐   ┌────────────────┐   ┌─────────────┐
│  Provision   │ → │  Bootstrap   │ → │ Deploy network │ → │ Tear down   │
│  §4–§6       │   │  §7–§10      │   │ §11–§12        │   │ §13.6       │
│  tofu apply  │   │  Argo sync   │   │ Agent / Argo   │   │ terminate   │
└──────────────┘   └──────────────┘   └────────────────┘   └─────────────┘
```

### 13.1 Platform Provisioning

From `infrastructure/`:

```bash
tofu init
tofu plan
tofu apply
```

Creates VPC, EKS, ENIs/SSM, IAM, EFS, ACM, Argo CD, and `cluster-bootstrap`.

### 13.2 Platform Bootstrap

Wait until Argo CD has synced required-apps (Multus, Istio, ingress, agent, …). Validate namespaces and `https://console.<domain>`.

### 13.3 Network Deployment

Use the Network Deployment Agent (or apply Applications/Workflows directly) to deploy Free5GC, subscribers, and UERANSIM per catalog options.

### 13.4 Runtime Operations

Monitor via Grafana/Loki; iterate scenarios via the agent; keep Multus IPs and Helm values aligned (§14); avoid resizing node groups without revisiting ENI/AZ assumptions.

### 13.5 Validation

Checklist:

- [ ] Nodes Ready with `controlplane=true` / `userplane=true`  
- [ ] Secondary interfaces up (`ens*`); Multus IPs on NF pods  
- [ ] Free5GC NFs Registered with NRF  
- [ ] UE registration and PDU session success  
- [ ] UPF N6 reachability as required  
- [ ] `console.<domain>` serves TLS  

### 13.6 Platform Teardown

Follow [terminate.md](../installation-instructions/terminate.md): remove Ingress/ALB-related resources first where required, then destroy OpenTofu-managed infrastructure to stop hourly charges.

---

# Part VI — Reference

## 14. IP Address Plan

### 14.1 Primary CIDR

Default `192.168.0.0/16` — Kubernetes nodes, pods (VPC CNI), Services, and load balancers.

### 14.2 Secondary CIDR

`100.64.0.0/16` — Multus / 5G reference-point interfaces only.

### 14.3 Multus Subnets

| Subnet | AZ (typical) | Use |
|--------|--------------|-----|
| `100.64.0.0/28` | eu-central-1b | UERANSIM gNB N2 |
| `100.64.1.0/28` | eu-central-1c | AMF N2 |
| `100.64.2.0/28` | eu-central-1b | UERANSIM gNB N3 |
| `100.64.3.0/28` | eu-central-1b | UPF N3 |
| `100.64.4.0/28` | eu-central-1c | SMF N4 |
| `100.64.5.0/28` | eu-central-1b | UPF N4 |
| `100.64.6.0/28` | eu-central-1b | UPF N6 |

Defined in `infrastructure/multus.tf`.

### 14.4 Static Network Function Addresses

| Role | Host ENI IP | Pod / NF IP (Helm) | Interface |
|------|-------------|--------------------|-----------|
| AMF N2 | `100.64.1.9` | `100.64.1.10` | `ens6` → NAD |
| SMF N4 | `100.64.4.9` | `100.64.4.10` | `ens7` |
| gNB N2 | `100.64.0.9` | chart-defined | Multus on UP node |
| gNB N3 | `100.64.2.9` | chart-defined | Multus on UP node |
| UPF N3 | `100.64.3.9` | `100.64.3.10` | `ens6` |
| UPF N4 | `100.64.5.9` | `100.64.5.10` | `ens7` |
| UPF N6 | `100.64.6.9` | `100.64.6.10` | `ens8` |

---

## 15. Configuration Reference

### 15.1 OpenTofu Variables

| Variable | Default / notes |
|----------|-----------------|
| `region` | `eu-central-1` |
| `bucket-name`, `key` | Required — S3 state |
| `vpc_name` | `cloud-5g-vpc` |
| `vpc_cidr` | `192.168.0.0/16` |
| `azs` | `["eu-central-1b", "eu-central-1c"]` |
| `eks_cluster_name` | `cloud-5g-eks` |
| `ami_id` | Ubuntu EKS AMI for region |
| `domain_name`, `zone_id` | Required — Cloudflare |
| `cloudflare_api_token` | Required — sensitive |
| `bedrock_region` | `""` → falls back to `region` |
| `bedrock_model_id` | Claude Haiku 4.5 inference profile |
| `git_repo_url` | Public platform repo URL |
| `git_repo_password` | Optional |

See `infrastructure/variables.tf` and `vars.auto.tfvars.example`.

### 15.2 Helm Values

Critical Free5GC globals (`5g/helm-charts/free5gc/values.yaml`): Multus `masterIf`, subnet, and `ipAddress` per reference point; `deployMongoDb` and per-NF toggles; node selectors for CP/UP. UERANSIM values must peer with AMF/UPF addresses in §14.

### 15.3 Environment Variables

| Context | Examples |
|---------|----------|
| VPC CNI | `WARM_ENI_TARGET=0` (§5.5.3) |
| Argo CD envsubst | `DOMAIN_NAME`, `ACM_CERTIFICATE_ARN`, `EFS_ID`, IRSA ARNs, `BEDROCK_*` |
| Network Deployment Agent | Catalog path, `GITHUB_RAW_BASE`, Bedrock region/model via chart values |

---

## 16. Repository Map

### 16.1 infrastructure/

| File | Role |
|------|------|
| `providers.tf` | Providers + S3 backend |
| `variables.tf` / `vars.auto.tfvars.example` | Inputs |
| `vpc.tf` | VPC, secondary CIDR, N6 route |
| `eks.tf` | Cluster, node groups, VPC CNI, node SG rules |
| `multus.tf` | Subnets, ENIs, Multus SGs/rules |
| `ssm.tf` | Bring up secondary interfaces |
| `iam.tf` | IRSA roles |
| `efs.tf` / `acm.tf` | Shared storage / TLS |
| `argocd.tf` | Argo CD install + cluster-bootstrap Application |
| `k8s_git-repo-secret.tf` | Repository registration |

### 16.2 cluster-bootstrap/

| Path | Role |
|------|------|
| `argocd-apps/required-apps/` | Child Applications (platform services) |
| `helm-charts/` | Multus, agent, and related charts |
| `k8s-resources/` | Ingress, storage, Istio resources |

### 16.3 5g/

| Path | Role |
|------|------|
| `deployment-catalog.yaml` | Agent capability inventory |
| `helm-charts/free5gc`, `ueransim` | NF charts |
| `argocd-apps/` | On-demand Applications |
| `argo-workflows/` | Multi-step deployments |

### 16.4 docs/

Installation guides, [arch diagrams](./), and this Architecture & Design Guide.

---

## 17. Glossary

### 17.1 AWS

**EKS** — Managed Kubernetes. **ENI** — Elastic Network Interface. **IRSA** — IAM Roles for Service Accounts. **ACM** — AWS Certificate Manager. **EFS** — Elastic File System. **SSM** — Systems Manager. **Bedrock** — Managed foundation-model API.

### 17.2 Kubernetes

**Pod / Service / Ingress** — Basic workload and exposure objects. **Helm** — Package manager for charts. **CNI / CSI** — Networking and storage plugins. **nodeSelector / labels** — Scheduling constraints.

### 17.3 5G Core

**Free5GC** — Open-source 5G core. **AMF / SMF / UPF / NRF / …** — 3GPP network functions implemented as CNFs in this lab.

### 17.4 3GPP

**N2** — AMF ↔ gNB (NGAP). **N3** — gNB ↔ UPF (GTP-U). **N4** — SMF ↔ UPF (PFCP). **N6** — UPF ↔ data network.

### 17.5 Networking

**Multus** — Multiple interfaces per pod. **Whereabouts** — IPAM CNI. **NAD** — NetworkAttachmentDefinition. **VPC CNI** — Primary AWS pod networking.

### 17.6 GitOps

**Argo CD** — Continuous reconciliation from Git. **App-of-apps** — Parent Application spawning children. **Argo Workflows** — Multi-step job orchestration.

### 17.7 AI

**Network Deployment Agent** — Console + backend for catalog-driven deploys. **Deployment catalog** — Declarative list of deployable options. **Claude Haiku 4.5** — Bedrock model used for intent parsing.

---

## 18. References

### 18.1 Project Documentation

- [Infrastructure installation](../installation-instructions/00%20infrastructure.md)
- [Network deployment](../installation-instructions/01%20network-deployment.md)
- [Architecture diagrams](./)
- [Teardown](../installation-instructions/terminate.md)

### 18.2 Related Repositories

- [5gcloudlabs/5g-platform-aws](https://github.com/5gcloudlabs/5g-platform-aws)
- [5gcloudlabs/network-deployment-agent](https://github.com/5gcloudlabs/network-deployment-agent)

### 18.3 External References

- [Amazon EKS](https://docs.aws.amazon.com/eks/)
- [Free5GC](https://www.free5gc.org/)
- [UERANSIM](https://github.com/aligungr/UERANSIM)
- [Multus CNI](https://github.com/k8snetworkplumbingwg/multus-cni)
- [Argo CD](https://argo-cd.readthedocs.io/) / [Argo Workflows](https://argo-workflows.readthedocs.io/)
- [Amazon Bedrock](https://docs.aws.amazon.com/bedrock/)
- [terraform-aws-modules](https://github.com/terraform-aws-modules)

---

*Document status: Architecture & Design Guide — Parts I–VI populated from repository implementation. Standalone diagram pages under `docs/arch/` remain visual companions.*
