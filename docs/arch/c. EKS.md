# Amazon EKS

**5G Platform AWS — Infrastructure Layer**

See the [Architecture Index](./README.md).

---

## Overview

Stage C provisions the Amazon EKS cluster that hosts the platform environment.

The solution uses two Amazon EKS managed node groups to separate 5G control-plane and user-plane workloads while maintaining a fully managed Kubernetes environment.

After the worker nodes are provisioned, OpenTofu configures the Amazon VPC CNI, attaches dedicated secondary Elastic Network Interfaces (ENIs) from the VPC secondary CIDR, applies security groups, and brings those interfaces online using AWS Systems Manager (SSM).

These secondary interfaces are later consumed by Multus, enabling Free5GC and UERANSIM to expose deterministic 3GPP reference points (N2, N3, N4, and N6) independently of Kubernetes networking.

---

## Architecture

<img width="4600" height="4600" alt="EKS Architecture" src="https://github.com/user-attachments/assets/c6a1b38f-58f5-4b7b-8eed-dbf6d1158d83" />

The Amazon EKS control plane is fully managed by AWS. Worker capacity is provided by two managed node groups deployed across separate Availability Zones.

This placement aligns with the Multus subnet design established in the [VPC stage](./b.%20VPC.md), allowing secondary interfaces to be attached within the same Availability Zone as their corresponding worker node.

### Managed Node Groups

| Node group | Role | Private subnet AZ | Kubernetes labels |
|------------|------|-------------------|-------------------|
| `5g-controlplane-node` | Free5GC control-plane network functions | `eu-central-1c` | `controlplane=true` |
| `5g-userplane-node` | UPF and UERANSIM | `eu-central-1b` | `userplane=true` |

### Secondary ENIs

| Worker node | ENI | Private IP | Device index | Reference point |
|-------------|-----|------------|--------------|-----------------|
| `5g-controlplane-node` | `amf-N2-eni` | `100.64.1.9` | 1 | AMF N2 |
| `5g-controlplane-node` | `smf-N4-eni` | `100.64.4.9` | 2 | SMF N4 |
| `5g-userplane-node` | `gnb-N2-eni` | `100.64.0.9` | 1 | gNB N2 |
| `5g-userplane-node` | `gnb-N3-eni` | `100.64.2.9` | 2 | gNB N3 |
| `5g-userplane-node` | `upf-N3-eni` | `100.64.3.9` | 3 | UPF N3 |
| `5g-userplane-node` | `upf-N4-eni` | `100.64.5.9` | 4 | UPF N4 |
| `5g-userplane-node` | `upf-N6-eni` | `100.64.6.9` | 5 | UPF N6 |

The secondary ENIs originate from the dedicated Multus subnets created during the VPC stage and provide deterministic addressing for all 5G network functions.

---

## Key Components

| Component | Responsibility |
|-----------|----------------|
| Amazon EKS Cluster | Managed Kubernetes control plane |
| Managed Node Groups | Dedicated control-plane and user-plane workers |
| Amazon VPC CNI | Provides primary pod networking and is configured for Multus compatibility |
| Secondary ENIs | Dedicated interfaces for 5G networking |
| AWS Systems Manager | Brings attached interfaces online after provisioning |
| Security Groups | Control traffic between 5G reference points and cluster resources |

---

## Provisioning Workflow

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

## Solution Implementation

### Cluster

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

The EKS module also creates the cluster and node security groups used by the control plane and worker instances. Additional rules are applied in [Security Group Rules](#security-group-rules).

---

### Managed Node Groups

Both node groups share a common worker configuration:

| Setting | Value |
|---------|-------|
| AMI | `var.ami_id` (Ubuntu EKS-optimized; default `ami-064c2479baf726e71`) |
| Disk | 30 GiB |
| SSM access | `AmazonSSMManagedInstanceCore` attached to the node IAM role |
| Scaling | `min_size = 1`, `max_size = 1`, `desired_size = 1` per group |

#### Control-plane node group

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

#### User-plane node group

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

### Amazon VPC CNI

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

### Secondary ENI Attachments

After the node groups exist, `multus.tf` looks up each worker by Name tag and attaches secondary ENIs from the Multus subnets created during the VPC stage.

Each ENI is tagged with `node.k8s.amazonaws.com/no_manage = true` so the VPC CNI does not manage or reclaim the interface.

#### Control-plane attachments

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

#### User-plane attachments

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

### Interface Initialization (AWS Systems Manager)

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

### Security Groups

The platform uses security groups at three layers: EKS-managed groups for the cluster and nodes, dedicated Multus ENI groups for 5G reference points, and an Amazon EFS group for shared storage.

#### Amazon EKS Security Groups

Created by the EKS module and referenced from `eks.tf`:

| Security group | Managed by | Attached to | Purpose |
|----------------|------------|-------------|---------|
| Cluster primary security group | EKS module | EKS control plane | Default cluster-to-node communication |
| Node security group | EKS module | Worker instances | Default node ingress/egress; extended by custom rules |

#### Multus Security Groups

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

#### Amazon EFS Security Group

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

### Security Group Rules

Custom rules extend the default EKS and Multus security groups.

#### Amazon EKS Rules

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

#### Multus Rules

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

## Provisioning Outcome

After this stage completes successfully, the platform environment contains:

- An Amazon EKS cluster with a publicly accessible API endpoint
- Two managed node groups dedicated to control-plane and user-plane workloads
- Amazon VPC CNI configured for Multus compatibility
- Secondary ENIs attached with deterministic IP addresses
- AWS Systems Manager automation for interface initialization
- Security groups protecting cluster and 5G network traffic
- A Kubernetes platform ready for cluster bootstrap and network-function deployment

---

## Troubleshooting

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

## Dependencies

The Amazon EKS platform provides the execution environment for subsequent infrastructure components.

- **IAM** configures IRSA and cluster identity.
- **Amazon EFS** provides persistent shared storage.
- **Platform Bootstrap** installs Argo CD, Multus, Whereabouts, Istio, and supporting platform services.
- **Free5GC** deploys control-plane network functions to the control-plane node group.
- **UERANSIM** and the **UPF** deploy to the user-plane node group using the attached secondary ENIs.
- **Network Deployment Agent** orchestrates deployment and lifecycle management of the network functions.
