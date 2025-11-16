<h1 align="center">Welcome to aws-5GCloudLabs !</h1>
<p align="center"><p align="center">An open-source project for deploying a complete 5G Core and UE/RAN simulation environment on AWS Cloud.</p></p>

<p align="center">
<img width="1831" height="2178" alt="aws-5g-cloud-lab-updated" src="https://github.com/user-attachments/assets/acf98f12-a974-4cb5-b622-9bc9b7b7523b" />
</p>

---

## Overview

Deploying a 5G Core network typically requires complex on-premise infrastructure and manual configuration.
**aws-5GCloudLabs** provides an automated and reproducible environment for deploying and testing the Free5GC 5G Core on Amazon EKS, eliminating the need for dedicated hardware or local setup.



---

## Building Blocks

The **aws-5GCloudLabs** environment brings together automated infrastructure provisioning, Kubernetes orchestration, observability, and 5G Core deployment — forming a complete and reproducible 5G lab on AWS.



#### **Infrastructure Automation**

- **OpenTofu** – Automates infrastructure provisioning using Infrastructure-as-Code (IaC) principles.



#### **AWS Services**

- **VPC** – Defines networking components including subnets, NAT gateways, internet gateways, and CIDR segmentation for infrastructure, Multus networks, and applications.  
- **EKS** – Managed Kubernetes cluster (CaaS), including node groups, compute nodes, kernel configuration, and user-data bootstrapping.  
- **EC2** – Compute resources, ENIs, security groups (virtual firewalls), and ALB integration points.  
- **SSM** – Secure node access and automation via SSM documents.  
- **EFS** – Shared persistent storage used by MongoDB (storing UDR subscriber data and NRF NF profiles).  
- **IAM / STS** – Authentication, authorization, and role management (including IRSA for EKS).  
- **Certificate Management** – Domain validation and TLS certificate provisioning for secure communications.
- **S3** – Stores the OpenTofu state file. Must be preconfigured before running the infrastructure deployment.  


#### **Kubernetes Add-ons and Integrations**

- **Argo CD** – Application lifecycle management via GitOps; syncs Helm charts from the repository.  
- **cert-manager** – Automates TLS certificate issuance and renewal to support end-to-end encryption.  
- **ExternalDNS** – Updates DNS records dynamically based on Kubernetes resources.  
- **Istio** – Ingress gateway and service-mesh capabilities for traffic management and observability.  
- **AWS Load Balancer Controller (ALB)** – Watches Ingress resources and provisions AWS ALBs accordingly.  
- **Multus** – CNI meta-plugin enabling multiple network interfaces per pod; used for 3GPP interface separation.  
- **Whereabouts** – IPAM provider assigning `/32` IPs as defined in NetworkAttachmentDefinitions (NADs).  
- **Prometheus, Grafana, Loki** – Monitoring, visualization, and centralized logging stack.



#### **External Integrations**

- **Let’s Encrypt** – Certificate authority used (via cert-manager) for automated certificate issuance and renewal.  
- **Cloudflare** – DNS provider for domain records and validation; requires an externally managed domain.



#### **Core 5G Applications**

- **Free5GC** – Open-source 5G Core implementation deployed via Argo CD.  
- **UERANSIM** – Open-source UE and gNodeB simulator for end-to-end validation and testing.

To understand how these components interact to deliver the full 5G deployment workflow, refer to the **[Architecture & Design](./architecture/README.md)** section.

---

## Installation Instructions

### 1. Prerequisites

#### Cloud Account Requirements

Before deploying any infrastructure, these must be available:

| Requirement | Description |
|------------|-------------|
| **AWS Account** | With permissions to create the required **AWS services** as described in the [AWS Services](#aws-services) section. |
| **Cloudflare Account** | With a **registered domain** and **API Token** with Edit permissions for the respective DNS zone. |


#### Local Workstation Requirements
Install the following tools locally:

| Requirement | Description |
|-------------|-------------|
| **AWS CLI** | [Install guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| **OpenTofu** | [Install guide](https://opentofu.org/docs/intro/install/) |
| **kubectl** | [Install guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/) |
| **Helm (optional)** | [Install guide](https://helm.sh/docs/intro/install/) |
| **Argo CD CLI (optional)** | [Install guide](https://argo-cd.readthedocs.io/en/stable/cli_installation/) |


Verify installs & versions

Run the following to confirm tools are installed:
```bash
aws --version
tofu version
kubectl version --client --short
helm version --short
argocd --version   
```

#### Configure AWS credentials

export AWS_ACCESS_KEY_ID=" "
export AWS_SECRET_ACCESS_KEY=" "
export AWS_REGION=" "
