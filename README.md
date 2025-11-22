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

#### a) Cloud Account Requirements

Before deploying any infrastructure, these must be available:

| Requirement | Description |
|------------|-------------|
| **AWS Account** | With permissions to create the required **AWS services** as described in the [AWS Services](#aws-services) section. |
| **Cloudflare Account** | With a **registered domain** + **API Token** with respective domain zone "DNS:Edit" permissions. |


#### b) Local Workstation Requirements
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

#### c) Configure AWS credentials

Generate AWS Access Keys from your AWS IAM console:  
https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html

Then configure the credentials using one of the following methods:

Option 1 — AWS CLI:
```bash
aws configure
AWS Access Key ID: "<access-key>"
AWS Secret Access Key: "<secret-key>"
Default region name: "<region>"
```

Option 2 — Environment Variables:

```bash
export AWS_ACCESS_KEY_ID="<access-key>"
export AWS_SECRET_ACCESS_KEY="<secret-key>"
export AWS_REGION="<region>"
```


#### d) Create an S3 Bucket for the OpenTofu State

aws s3api create-bucket --bucket $bucket-name --create-bucket-configuration LocationConstraint=$region

OpenTofu requires an S3 bucket to store its remote state file.  
Create the bucket using one of the following commands:

For `us-east-1` (no LocationConstraint required):
```bash
aws s3api create-bucket --bucket <bucket-name>
```
For all other AWS regions:
```bash
aws s3api create-bucket --bucket <bucket-name> --create-bucket-configuration LocationConstraint=$AWS_REGION
```

### 2. Clone repository 

Download the `aws-5GCloudLabs` project to your local workstation, either via SSH or HTTPS:

SSH:
```bash
git clone git@github.com:5g-cloud-labs/aws-5gcloudlabs.git
```
HTTPS:
```bash
git clone https://github.com/5g-cloud-labs/aws-5gcloudlabs.git
```

### 3. Install Infrastructure Using OpenTofu

After completing all prerequisites, you can deploy the AWS infrastructure and the Kubernetes add-ons using **OpenTofu**.

#### a) Initialize and Deploy Infrastructure

Go to the infrastructure folder and run the required OpenTofu commands:

```bash
cd aws-5gcloudlabs/infrastructure
opentofu init
opentofu plan
opentofu apply
```
The OpenTofu configuration performs the following:

Provisions all AWS resources (VPC, EKS, EC2, EFS, TLS Certificate, IAM roles, etc.).

Deploys several Kubernetes add-ons directly using helm_release resources.

Applies the Argo CD required-apps Application using a kubectl_manifest resource, which triggers Argo CD to fetch all remaining add-ons from the Git repository.

#### b) Validate the Deployment
Once opentofu apply completes, perform the checks below to confirm the EKS cluster, Argo CD bootstrap, add-ons and ingress are healthy and reachable.

##### - Update kubeconfig and verify EKS connectivity

Configure `kubectl` for the new cluster and verify node readiness:

```bash
aws eks update-kubeconfig --region "$AWS_REGION" --name "$EKS_CLUSTER_NAME"
kubectl get nodes --no-headers
```
You should see 2 worker nodes in Ready state.

```bash
example
```

##### - Confirm Argo CD applications are synced
Check that Argo CD has successfully deployed the required-apps Application and its child applications:

```bash
kubectl -n argocd get app required-apps
```

The status should show Synced and Healthy.
```bash
example
```

### 4.Deploy 5G Core

You can deploy the 5G Core using one of two methods, depending on your workflow preference:

#### **Option 1 — Deploy via CLI**

Use the provided **bash script** in the repository to trigger the 5G Core deployment.

Navigate to the `scripts/cli` directory and run the deployment script:

```bash
cd aws-5gcloudlabs/scripts/cli
./free5gc-cli.sh
```


#### **Option 2 — Deploy via Console UI**

Use the web-based Console UI to input configuration parameters and trigger the deployment interactively.  




Validation (k8s, helm, argo-cli, argo-ui)

### 5. 5G Subscribers 

validation

### 6. UERAMSIM

validation (reg & PDU est automatically)

ping

grafana


