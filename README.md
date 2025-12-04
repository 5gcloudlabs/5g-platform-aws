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
| **Helm** | [Install guide](https://helm.sh/docs/intro/install/) |
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

Generate AWS **[Access Keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)** from your AWS IAM console.

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

**Navigate to the infrastructure directory:** 

```bash
cd aws-5gcloudlabs/infrastructure
```
**Initialize infrastructure directory:**
```bash
/aws-5gcloudlabs/infrastructure$ tofu init
```
Expected Output:
```bash
...
```

**Create execution plan:**
```bash
/aws-5gcloudlabs/infrastructure$ tofu plan
```
Expected Output:
```bash
Plan: 178 to add, 0 to change, 0 to destroy.
```

**Plan execution:**

```bash
/aws-5gcloudlabs/infrastructure$ tofu apply
```
Expected Output:
```bash
Apply complete! Resources: 178 added, 0 changed, 0 destroyed.
```

The OpenTofu configuration performs the following:

Provisions all AWS resources (VPC, EKS, EC2, EFS, TLS Certificate, IAM roles, etc.).

Deploys several Kubernetes add-ons directly using helm_release resources.

Applies the Argo CD required-apps Application using a kubectl_manifest resource, which triggers Argo CD to fetch all remaining add-ons from the Git repository.

#### b) Validate infrastructure creation
Once opentofu apply completes, perform the checks below to confirm the EKS cluster, Argo CD bootstrap, add-ons and ingress are healthy and reachable.

##### - Update kubeconfig and verify EKS connectivity

Configure `kubectl` for the new cluster and verify node readiness:

```bash
aws eks update-kubeconfig --region "$AWS_REGION" --name "<EKS_CLUSTER_NAME>"
Updated context arn:aws:eks:eu-central-1:**********:cluster/cloud-5g-eks in /home/barakota/.kube/config
```
You should see 2 worker nodes in Ready state.

```bash
kubectl get nodes
NAME                                              STATUS   ROLES    AGE   VERSION
ip-192-168-119-14.eu-central-1.compute.internal   Ready    <none>   13m   v1.29.15
ip-192-168-36-219.eu-central-1.compute.internal   Ready    <none>   13m   v1.29.15
```

##### - Verify the below helm charts are deployed successfully via OpenTofu:
```bash
helm list -A
NAME                        	        NAMESPACE               STATUS         	CHART                                  	 APP VERSION
argocd                      	        argocd      	        deployed       	argo-cd-8.2.5                      	     v3.0.12    
aws-efs-csi-driver          	        kube-system 	        deployed       	aws-efs-csi-driver-3.2.1           	     2.1.10     
aws-load-balancer-controller	        kube-system 	        deployed       	aws-load-balancer-controller-1.13.4	     v2.13.4    
cert-manager                 	        cert-manager	        deployed       	cert-manager-v1.18.2               	     v1.18.2    
external-dns                	        kube-system 	    	  deployed        external-dns-1.19.0                      0.19.0     
istio-base                  	        istio-system	        deployed       	base-1.26.3                        	     1.26.3     
istio-gateway               	        istio-system	        deployed       	gateway-1.26.3                     	     1.26.3     
istiod                      	        istio-system	        deployed       	istiod-1.26.3                      	     1.26.3     
```

These Helm charts are deployed automatically through **OpenTofu** using the `helm_release` resource as part of the **cluster bootstrapping** process. Some add-ons require tight integration with AWS, including:

- <sub><strong>IAM Roles for Service Accounts (IRSA)</strong></sub> for the AWS Load Balancer Controller and EFS CSI Driver  
- <sub><strong>ExternalDNS</strong></sub> and <sub><strong>cert-manager</strong></sub>, which use runtime variables such as `var.domain_name` to create DNS records and TLS certificates  
- <sub><strong>Argo CD</strong></sub>, which is deployed early to manage the lifecycle of all remaining Git-based application deployments  



##### - Verify Argo CD applications are synced
Confirm that Argo CD has successfully deployed the `required-apps` Application and all dependent applications, completing the cluster bootstrapping process.
The status should display **Synced** and **Healthy**:


```bash
kubectl -n argocd get apps
NAME                         SYNC STATUS   HEALTH STATUS
console-app                  Synced        Healthy
curl-app                     Synced        Healthy
executor-app                 Synced        Healthy
kube-prometheus-stack        Synced        Healthy
kube-prometheus-stack-crds   Synced        Healthy
loki                         Synced        Healthy
multus                       Synced        Healthy
required-apps                Synced        Healthy
whereabouts                  Synced        Healthy

```


### 4. End-to-End 5G Network Deployment:  
Deploy all 5G network components, including the Free5GC Core, subscribers creation, and UERANSIM either via CLI or via Console-UI.

#### A) 5G Network Deployment via CLI:

##### 1. Deploy 5G Core via CLI

Use the provided **bash script** in the repository to trigger the 5G Core deployment.

Navigate to the `scripts/cli` directory and run the deployment script:

```bash
cd aws-5gcloudlabs/scripts/cli
./free5gc-cli.sh
```

You will be prompted to enter the PLMN-ID for your Network:

Example prompt: 
```bash
Configure the PLMN-ID for your 5G Core Network (MCC + MNC).

1. Enter a 3-digit Mobile Country Code (MCC), example: 602
2. Enter a 2-digit Mobile Network Code (MNC), example: 02

```

Expected Output. you should see output similar to: 
```bash
application.argoproj.io/free5gc-app created
```



###### Validate the 5G Core Deployment

After triggering the deployment, you can verify that the 5G Core components are running using several methods.

1. Verify using kubectl

Check that all Free5GC pods are starting correctly and reaching a Running status.

```bash
kubectl -n free5gc get pods
NAME                                                   READY   STATUS    
aws-5gcloudlabs-free5gc-amf-amf-f69db95f-f6csq         2/2     Running   
aws-5gcloudlabs-free5gc-ausf-ausf-585956b99c-zn82d     2/2     Running   
aws-5gcloudlabs-free5gc-nrf-nrf-549dd59dc4-xwxq7       2/2     Running   
aws-5gcloudlabs-free5gc-nssf-nssf-778f45f96c-zrqcn     2/2     Running   
aws-5gcloudlabs-free5gc-pcf-pcf-68b4f8fb7c-cs6lq       2/2     Running   
aws-5gcloudlabs-free5gc-smf-smf-cb7944cc5-24nth        2/2     Running   
aws-5gcloudlabs-free5gc-udm-udm-7476888578-s896f       2/2     Running   
aws-5gcloudlabs-free5gc-udr-udr-cb876bdf6-5f9f5        2/2     Running   
aws-5gcloudlabs-free5gc-upf-upf-67dd5464f4-975zp       2/2     Running   
aws-5gcloudlabs-free5gc-webui-webui-6876d69c77-8bldv   2/2     Running   
mongodb-0                                              2/2     Running   
```


##### 2. 5G Subscribers Creation via CLI

After validating that your 5G Core has been successfully deployed, you can proceed to create 5G subscribers using the command-line provisioning tool.

This step uses the generated script:

```bash
subscriber-provisioner-cli.sh
```

1. Navigate to the CLI directory

Make sure you are in the same directory where the scripts were generated:

```bash
cd scripts/cli
```
2. Run the Subscriber Provisioning Script

Execute the script*:

```bash
./subscriber-provisioner-cli.sh

```

You will be prompted to enter the number of test subscribers you would like to create:

Example prompt: 
```bash
Enter the number of subscribers to provision
```

Expected Output:
```bash
===== Provisioned IMSI List =====
```

*This script is automatically created when you run free5gc-cli.sh.
The original template file, subscriber-provisioner-cli.base, contains placeholder variables ($mcc, $mnc) which are replaced during the environment substitution step.


# validation


##### 3. Deploy UERANSIM (UE + gNB) Simulation via CLI

After deploying the 5G Core and creating subscribers, you can deploy **UERANSIM** using the provided CLI script.

Navigate to the `scripts/cli` directory and run:

```bash
cd aws-5gcloudlabs/scripts/cli
./ueransim-cli.sh
```
Expected output

```bash
application.argoproj.io/ueransim-app created
```

Validate UERANSIM Deployment

Use kubectl to confirm the gNB and UE pods are running:
```bash
kubectl -n ueransim get pods
```

You should see the following pods in Running state:

# validate


#### B) Deployment via Console-UI

You can deploy the 5G Core using the AWS 5G Cloud Labs Web Console, which provides an interactive UI for entering MCC/MNC values and triggering the deployment pipeline.

Steps

1. Open the Console UI in your browser:

```bash
https://console.<your-domain>
```

2. Navigate to the 5G Core Deployment page.

3. Enter the required PLMN values:

MCC – Mobile Country Code (3 digits), example: 602

MNC – Mobile Network Code (2 digits), example: 02

4. Click Deploy 5G Core.





validation (reg & PDU est automatically)

ping

grafana


