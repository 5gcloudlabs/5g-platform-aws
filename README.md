<h1 align="center">Welcome to aws-5GCloudLabs !</h1>
<p align="center"><p align="center">An open-source project for deploying 5G Core network pre-integrated with UE/RAN simulation environment on AWS Cloud.</p></p>

<p align="center">
<img width="600" height="4000" alt="main (2)" src="https://github.com/user-attachments/assets/09287ae6-25ef-4596-bacb-844dd08f2868" />
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
- **AWS Certificate Manager** – Domain validation and TLS certificate provisioning for secure communications.
- **S3** – Stores the OpenTofu state file. Must be preconfigured before running the infrastructure deployment.  


#### **Kubernetes Add-ons and Integrations**

- **AWS Load Balancer Controller (AWS LBC)** – Watches Ingress resources and provisions AWS ALB accordingly.
- **AWS EFS CSI Driver**– The Amazon EFS CSI Driver enables Kubernetes to provision and manage Amazon EFS file systems.
- **ExternalDNS** – Updates DNS records dynamically based on Kubernetes resources.  
- **cert-manager** – Automates TLS certificate issuance and renewal to support end-to-end encryption.  
- **Istio** – `Ingress Gateway` as reverse proxy in addition to `Service-Mesh` capabilities for traffic management and observability.  
- **Multus** – CNI meta-plugin enabling multiple network interfaces per pod; used for 3GPP interface separation.  
- **Whereabouts** – IPAM provider automatically assigns IP addresses based on the configured NetworkAttachmentDefinitions (NADs).  
- **Prometheus, Grafana, Loki** – Monitoring, visualization, and centralized logging stack.
- **Argo CD** – Application lifecycle management via GitOps; syncs Helm charts from the repository.  


#### **External Integrations**

- **Let’s Encrypt** – Certificate authority used (via cert-manager) for automated certificate issuance and renewal.  
- **Cloudflare** – DNS provider for domain records and validation; requires an externally managed domain.



#### **5G Applications**

- **Free5GC** – Open-source 5G Core implementation deployed via Argo CD.  
- **UERANSIM** – Open-source UE and gNodeB simulator for end-to-end validation and testing.

To understand how these components interact to deliver the full 5G deployment workflow, refer to the **[Arch&Design](./docs/Arch&Design)** section.

---
