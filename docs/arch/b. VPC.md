# VPC architecture

5G Platform AWS — infrastructure layer. See [architecture index](./README.md).

# Networking

## Purpose

Stage B establishes the AWS networking foundation for the platform environment. Every subsequent component—including Amazon EKS, Multus, Free5GC, and UERANSIM—depends on this networking layer.

The design separates Kubernetes networking from 5G network traffic by assigning them to different IP address spaces:

- **Cluster networking** uses the primary VPC CIDR (`192.168.0.0/16` by default) for Kubernetes pods, services, worker nodes, and ingress traffic.
- **5G networking** uses a dedicated secondary CIDR (`100.64.0.0/16`) from which Multus allocates secondary interfaces for Free5GC and UERANSIM network functions.

This separation allows network functions to expose stable interfaces for 3GPP reference points (N2, N3, N4, and N6) while remaining integrated with the Kubernetes networking model.

---

## Architecture

```text
https://github.com/user-attachments/assets/e38a14dd-8e28-4196-8bbd-4548a09921df
```

The primary CIDR provides standard Kubernetes networking, while the secondary CIDR is reserved exclusively for Multus-attached interfaces used by 5G network functions.

---

## Components

| Component | Responsibility |
|-----------|----------------|
| VPC | Creates the primary AWS networking environment, including public and private subnets |
| Secondary CIDR | Adds a dedicated address space for 5G interfaces |
| Multus Subnets | Allocates individual Layer-3 networks for each 5G interface |
| NAT Gateways | Provides outbound internet access for private resources |
| N6 Route Table | Routes user-plane traffic from the UPF N6 subnet to the NAT Gateway |

---

## Control Flow

```text
tofu apply
      │
      ▼
Create VPC
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
Networking Ready
```

The networking layer is provisioned before Amazon EKS node groups are created. Later stages attach secondary ENIs from the Multus subnets to worker nodes, allowing network functions to receive deterministic secondary IP addresses.

---

## Implementation

### Primary VPC

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

Public subnets host internet-facing load balancers, while private subnets host Amazon EKS worker nodes.

Subnet tags enable automatic discovery by Amazon EKS and the AWS Load Balancer Controller.

A NAT Gateway is created in each Availability Zone to provide outbound internet connectivity for workloads running in private subnets.

To reduce race conditions during provisioning, Terraform waits briefly after the VPC has been created before configuring dependent resources.

```terraform
resource "time_sleep" "sleep-after-vpc-creation" {
  depends_on = [module.vpc]

  create_duration = "3m"
}
```

---

### Secondary CIDR

A secondary CIDR (`100.64.0.0/16`) is associated with the VPC to isolate 5G interface addressing from Kubernetes networking.

```terraform
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = module.vpc.vpc_id
  cidr_block = "100.64.0.0/16"
}
```

This address space is reserved exclusively for Multus-attached interfaces.

---

### N6 Routing

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

### Multus Subnets

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

The Helm charts for Free5GC and UERANSIM are intentionally aligned with this networking design, assigning deterministic IP addresses from these subnet ranges to each network function.

---

## Result

After this stage completes successfully, the platform environment contains:

- A VPC with primary and secondary CIDRs
- Public and private subnets
- NAT Gateways
- Dedicated Multus subnets
- An N6 route table
- Networking ready for Amazon EKS and Multus integration

---

## Troubleshooting

| Symptom | Possible Cause | Investigation |
|----------|----------------|---------------|
| Secondary CIDR association fails | CIDR already exists in the AWS account or Region | `aws_vpc_ipv4_cidr_block_association.secondary_cidr` |
| Pods receive no Multus IP address | Worker node and subnet are in different Availability Zones | Compare `multus.tf` subnet AZs with EKS node groups |
| UPF cannot reach the internet | Missing N6 route or NAT Gateway configuration | Verify the N6 route table and NAT Gateway |
| Application Load Balancer is not created | Missing subnet discovery tags | Review `public_subnet_tags` in `vpc.tf` |

---

## Next Stages

The networking layer provides the foundation for the remaining platform components.

- **Compute** provisions Amazon EKS worker nodes into the private subnets.
- **Network Interfaces** attach secondary ENIs from the Multus subnets to those worker nodes.
- **Platform Bootstrap** installs Multus CNI and Whereabouts IPAM.
- **Network Deployment** assigns deterministic secondary IP addresses to Free5GC and UERANSIM network functions.

