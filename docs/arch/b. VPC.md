# VPC

**5G Platform AWS — Infrastructure Layer**

See the [Architecture Index](./README.md).

---

## Overview

Stage B establishes the AWS networking foundation for the platform environment. Every subsequent component—including Amazon EKS, Multus, Free5GC, and UERANSIM—depends on this networking layer.

The design separates Kubernetes networking from 5G network traffic by assigning them to different IP address spaces:

- **Cluster networking** uses the primary VPC CIDR (`192.168.0.0/16` by default) for Kubernetes pods, services, worker nodes, and ingress traffic.
- **5G networking** uses a dedicated secondary CIDR (`100.64.0.0/16`) from which Multus allocates secondary interfaces for Free5GC and UERANSIM network functions.

This separation allows network functions to expose stable interfaces for 3GPP reference points (N2, N3, N4, and N6) while remaining integrated with the Kubernetes networking model.

---

## VPC Architecture

<img width="5559" height="4600" alt="VPC Architecture" src="https://github.com/user-attachments/assets/ca953fea-361b-40f3-81e0-9b701c1b6fb3" />

The VPC consists of two independent networking domains:

- A **primary CIDR** that provides standard AWS and Kubernetes networking.
- A **secondary CIDR** dedicated to Multus-attached interfaces used by 5G network functions.

This architecture enables Kubernetes workloads to operate using the standard VPC CNI while Free5GC and UERANSIM receive deterministic secondary interfaces for 3GPP reference points.

---

## Key Components

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

## Provisioning Workflow

```text
tofu apply
      │
      ▼
Create VPC
      │
      ▼
Create Public & Private Subnets
      │
      ▼
Associate Secondary CIDR
      │
      ▼
Create Multus Subnets
      │
      ▼
Configure NAT Gateways
      │
      ▼
Configure N6 Routing
      │
      ▼
VPC Ready
```

The networking infrastructure is provisioned before Amazon EKS worker nodes are created.

Later stages attach secondary Elastic Network Interfaces (ENIs) from the Multus subnets to worker nodes, enabling network functions to receive deterministic secondary IP addresses.

---

## Solution Implementation

### VPC

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

### Secondary VPC CIDR

A secondary CIDR (`100.64.0.0/16`) is associated with the VPC to isolate 5G interface addressing from Kubernetes networking.

```terraform
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = module.vpc.vpc_id
  cidr_block = "100.64.0.0/16"
}
```

This address space is reserved exclusively for Multus-attached interfaces.

---

### N6 Routing Configuration

The UPF N6 interface provides user-plane connectivity toward external networks.

A dedicated route table forwards outbound traffic from the UPF N6 subnet through the VPC NAT Gateway.

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

### Multus Network Subnets

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
- UERANSIM N2
- UERANSIM N3

These subnets are later used by Multus to attach secondary interfaces to Kubernetes pods.

The Free5GC and UERANSIM Helm charts are intentionally aligned with this networking design, assigning deterministic IP addresses from these subnet ranges to each network function.

---

## Provisioning Outcome

After this stage completes successfully, the platform environment contains:

- A VPC with primary and secondary IPv4 CIDRs
- Public subnets for internet-facing load balancers
- Private subnets for Amazon EKS worker nodes
- One NAT Gateway per Availability Zone
- Dedicated `/28` Multus subnets for 5G interfaces
- An N6 route table associated with the UPF N6 subnet
- Networking ready for Amazon EKS, Multus, and platform bootstrap

---

## Troubleshooting

| Symptom | Possible Cause | Investigation |
|----------|----------------|---------------|
| Secondary CIDR association fails | CIDR already exists in the AWS account or Region | `aws_vpc_ipv4_cidr_block_association.secondary_cidr` |
| Pods receive no Multus IP address | Worker node and subnet are deployed in different Availability Zones | Compare `multus.tf` subnet AZs with the Amazon EKS node groups |
| UPF cannot reach the internet | Missing N6 route or NAT Gateway configuration | Verify the N6 route table and NAT Gateway |
| Application Load Balancer is not created | Missing subnet discovery tags | Review `public_subnet_tags` in `vpc.tf` |

---

## Dependencies

The VPC provides the networking foundation for subsequent platform components.

- **Amazon EKS** deploys worker nodes into the private subnets.
- **Elastic Network Interfaces (ENIs)** are attached to worker nodes from the Multus subnets.
- **Platform Bootstrap** installs Multus CNI and Whereabouts IPAM.
- **Free5GC** and **UERANSIM** receive deterministic secondary IP addresses from the Multus subnet ranges.
- **Network Deployment Agent** deploys network functions that rely on this networking model.
