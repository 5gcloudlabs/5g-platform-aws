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

##### - Verify the below helm charts are deployed successfully via OpenTofu*: 
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

These Helm charts are deployed during cluster bootstrapping using `helm_release` in OpenTofu. While not the typical recommendation for managing Helm charts, it’s required because:

**AWS Load Balancer** Controller and **EFS CSI Driver** need the AWS `IAM role ARNs` created by OpenTofu so their service accounts can be annotated for IRSA.

**ExternalDNS** and cert-manager rely on runtime variable `var.domain_name` to create DNS records and TLS certificate.

**Argo CD** must be installed early so it can manage all remaining Git-based deployments.

##### - Ensure the respective pods are deployed successfully

-  Verify that the `aws-load-balancer-controller` and `aws-efs-csi-driver` pods are running as expected in the kube-system namespace. Additionally, you may validate the health of the remaining system components deployed in this namespace.

```bash
  kubectl -n kube-system get pods
```  
Expected Outcome:

```bash
NAME                                            READY   STATUS    
aws-load-balancer-controller-7896c5c598-8dbxq   1/1     Running   
aws-node-5p9hs                                  2/2     Running   
aws-node-6k54j                                  2/2     Running   
coredns-54d96d77bc-9gv6m                        1/1     Running   
coredns-54d96d77bc-dt88g                        1/1     Running   
efs-csi-controller-649b9665d7-6xwtv             3/3     Running   
efs-csi-controller-649b9665d7-sz6vz             3/3     Running   
efs-csi-node-gpq99                              3/3     Running   
efs-csi-node-wdc49                              3/3     Running   
external-dns-549fbd7b7-r5pp2                    1/1     Running   
kube-multus-ds-8bb6q                            1/1     Running   
kube-multus-ds-m7rrk                            1/1     Running   
kube-proxy-ccr8q                                1/1     Running   
kube-proxy-dsmqv                                1/1     Running   
whereabouts-whereabouts-chart-2mr5j             1/1     Running   
whereabouts-whereabouts-chart-sdsbq             1/1     Running   
```

- Verfiy that all cert-manager components (including the controller, webhook, and CA injector) are running as expected in the cert-manager namespace. These services are required for issuing TLS certificates for cluster services and ingress resources.

```bash
  kubectl -n cert-manager get pods
```  
Expected Outcome:

```bash
NAME                                      READY   STATUS  
cert-manager-595b985855-scchf             1/1     Running 
cert-manager-cainjector-dd577f84c-zgl95   1/1     Running 
cert-manager-webhook-79cd9bf9d-kz86t      1/1     Running
```

- Verify that the Istio control plane components—such as istiod, the ingress gateway, and base system pods—are running properly in the istio-system namespace. These components provide the service mesh foundation and ingress routing for the platform.

```bash
  kubectl -n istio-system get pods
```  
Expected Outcome:

```bash
NAME                             READY   STATUS   
istio-gateway-5dcdfc6df6-m2bps   1/1     Running  
istiod-556bf8849c-7qfs4          1/1     Running  

```

Confirm that all Argo CD components (API server, repository server, application controller, and Redis) are running and healthy in the argocd namespace. A fully functional Argo CD installation is required for managing GitOps-driven application deployments.


```bash
  kubectl -n argocd get pods
```  
Expected Outcome:

```bash
NAME                                                READY   STATUS  
argocd-application-controller-0                     1/1     Running 
argocd-applicationset-controller-56c9b5889f-lhb9l   1/1     Running 
argocd-dex-server-659554d859-82zsb                  1/1     Running 
argocd-notifications-controller-67c4db49fd-7p77m    1/1     Running 
argocd-redis-7c5f9cbc5b-5cpqq                       1/1     Running 
argocd-repo-server-549b88f9f-cvspp                  1/1     Running 
argocd-server-6b896f4dcc-2rqmh                      1/1     Running 
```

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

##### - Ensure the respective pods are deployed successfully

- **Monitoring & Observability stack:**

```bash
kubectl -n monitoring get pods
```

Expected Output:
```bash
NAME                                                        READY   STATUS  
kube-prometheus-stack-grafana-7bc5ccb655-864lt              3/3     Running 
kube-prometheus-stack-kube-state-metrics-668f8bbd5f-f95tr   1/1     Running 
kube-prometheus-stack-operator-7fd5b447b-hjpx6              1/1     Running 
kube-prometheus-stack-prometheus-node-exporter-57vjf        1/1     Running 
kube-prometheus-stack-prometheus-node-exporter-qgbf9        1/1     Running 
loki-0                                                      1/1     Running 
loki-promtail-568m2                                         1/1     Running 
loki-promtail-84cm6                                         1/1     Running 
prometheus-kube-prometheus-stack-prometheus-0               2/2     Running 
```

- **Console UI, executor, and curl helper pods:**
```bash
kubectl get pods
```
Expected Output:
```bash
NAME                               READY   STATUS  
console-8c88b9cf9-h9vzx            1/1     Running 
curl-deployment-5db9cb8c57-hjdkc   1/1     Running 
executor-9f5589868-qp9gq           1/1     Running 
```

- **Multus and Whereabouts:**
Already validated in an earlier step, but you can re-check if needed:
```bash
kubectl -n kube-system get pods
```
Expected Output:
```bash
NAME                                            READY   STATUS    
aws-load-balancer-controller-7896c5c598-8dbxq   1/1     Running   
aws-node-5p9hs                                  2/2     Running   
aws-node-6k54j                                  2/2     Running   
coredns-54d96d77bc-9gv6m                        1/1     Running   
coredns-54d96d77bc-dt88g                        1/1     Running   
efs-csi-controller-649b9665d7-6xwtv             3/3     Running   
efs-csi-controller-649b9665d7-sz6vz             3/3     Running   
efs-csi-node-gpq99                              3/3     Running   
efs-csi-node-wdc49                              3/3     Running   
external-dns-549fbd7b7-r5pp2                    1/1     Running   
kube-multus-ds-8bb6q                            1/1     Running   
kube-multus-ds-m7rrk                            1/1     Running   
kube-proxy-ccr8q                                1/1     Running   
kube-proxy-dsmqv                                1/1     Running   
whereabouts-whereabouts-chart-2mr5j             1/1     Running   
whereabouts-whereabouts-chart-sdsbq             1/1     Running   
```

##### Validate Ingress and DNS Resolution

As a final validation step, ensure the Ingress resource is deployed correctly, the CNAME records exist, and DNS resolves to the ALB IPs.

###### 1. Verify the ALB Ingress configuration
Check that the Ingress resource is created with the correct hosts, annotations including ACM TLS certificate ARN:

```bash
kubectl -n istio-system describe ingress ingress
```

Expected Output:
```bash
Name:             ingress
Labels:           <none>
Namespace:        istio-system
Address:          k8s-istiosys-ingress-9190591614-1233209419.eu-central-1.elb.amazonaws.com
Ingress Class:    <none>
Default backend:  <default>
Rules:
  Host                    Path  Backends
  ----                    ----  --------
  console.$domain_name     
                          /   istio-gateway:443 (192.168.41.38:443)
  argocd.$domain_name      
                          /   istio-gateway:443 (192.168.41.38:443)
  grafana.$domain_name     
                          /   istio-gateway:443 (192.168.41.38:443)
  webui.$domain_name       
                          /   istio-gateway:443 (192.168.41.38:443)
  prometheus.$domain_name  
                          /   istio-gateway:443 (192.168.41.38:443)
Annotations:              alb.ingress.kubernetes.io/backend-protocol: HTTPS
                          alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:eu-central-1:************:certificate/f7b0eeb2-bd46-464e-8bc1-be02c18797fd
                          alb.ingress.kubernetes.io/healthcheck-interval-seconds: 30
                          alb.ingress.kubernetes.io/healthcheck-path: /healthz
                          alb.ingress.kubernetes.io/listen-ports: [{"HTTP": 80}, {"HTTPS":443}]
                          alb.ingress.kubernetes.io/scheme: internet-facing
                          alb.ingress.kubernetes.io/target-type: ip
                          kubernetes.io/ingress.class: alb
Events:                   <none>
```

###### 2. Validate that DNS resolves to the ALB
Run `dig` against the ALB hostname shown under the **Address** field:

```bash
dig k8s-istiosys-ingress-9190591614-1233209419.eu-central-1.elb.amazonaws.com
```

Expected Output:
```bash
ANSWER SECTION:
k8s-istiosys-ingress-...elb.amazonaws.com. 60 IN A 3.126.96.223
k8s-istiosys-ingress-...elb.amazonaws.com. 60 IN A 18.194.188.63
```

### 4. End-to-End 5G Network Deployment:  
Deploy the 5G Core, provision test subscribers, and launch the UE & gNB simulation — either via CLI or Console-UI.

#### A) 5G Network Deployment via CLI:

##### 1. Deploy 5G Core via CLI

Use the provided **bash script** in the repository to trigger the 5G Core deployment.

Navigate to the `scripts/cli` directory and run the deployment script:

```bash
cd aws-5gcloudlabs/scripts/cli
./free5gc-cli.sh
```

You will be prompted to enter the PLMN-ID for your Network, here we input 602 as value for mcc and 02 as value for mnc

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

1. Validate 5G Core Pod Status

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

2. Validate SBI Registration (NF Registration Check)


Free5GC network functions (AMF, SMF, UDM, AUSF, etc.) register with the NRF over the Service-Based Interface (SBI).

You can verify that a Network Function is successfully registered by checking its entry in the NRF database. The NRF stores its registrations inside MongoDB (along with other Free5GC databases).

You can verify e.g AMF registration by running the command below:

```bash
kubectl -n free5gc exec -it mongodb-0 --   mongo free5gc --eval 'db.NfProfile.find({ nfType: "AMF" }).pretty()'
```

Expected Output:


You only need to verify the key fields shown below (your real output will contain many more details):

```bash
{
  "nfType": "UDM",
  "nfStatus": "REGISTERED",
  "plmnList": [
     { "mcc": "602", "mnc": "02" }
    ],
  "ipv4Addresses": ["aws-5gcloudlabs-free5gc-udm-service"],
  "nfServices": [
    { "serviceName": "nudm-ee",   "nfServiceStatus": "REGISTERED" },
    { "serviceName": "nudm-pp",   "nfServiceStatus": "REGISTERED" },
    { "serviceName": "nudm-sdm",  "nfServiceStatus": "REGISTERED" },
    { "serviceName": "nudm-uecm", "nfServiceStatus": "REGISTERED" },
    { "serviceName": "nudm-ueau", "nfServiceStatus": "REGISTERED" }
  ]
}

```

##### 2. 5G Subscribers Creation via CLI

After validating that your 5G Core has been successfully deployed, you can proceed to provision 5G subscribers via script.

1. Make sure you are in the same `cli` directory:

```bash
cd aws-5gcloudlabs/scripts/cli
```

2. Run the Subscriber Provisioning Script

Execute the script*:

```bash
./subscriber-provisioner-cli.sh

```

You will be prompted to enter how many test subscribers you want to provision. In this example, we use 2.

Example prompt: 
```bash
Enter the number of subscribers to provision (e.g: 10): 2
```

Expected Output:
```bash
*** Starting provisioning of (2) subscribers with IMSI range beginning at (602020000000001) ***

Please wait...


===== Provisioned IMSI List =====

602020000000001
602020000000002
```
IMSI numbering starts at $mcc.$mnc.0000000001.

*This script is automatically created when you run free5gc-cli.sh.
The original template file, subscriber-provisioner-cli.base, contains placeholder variables ($mcc, $mnc) which are replaced during the environment substitution step.


###### Validate subscriber provisioning:

To validate subscriber provisioning via CLI, check the script output file `subs-prov-output.log`

```bash
more subs-prov-output.log
```
Expected Output:

Find the POST request and scroll down to the HTTP/1.1 201 Created line — this indicates successful subscriber creation.

```bash
> POST /api/subscriber/imsi-602020000000001/60202 HTTP/1.1
> 
> 
< HTTP/1.1 201 Created
...
> POST /api/subscriber/imsi-602020000000002/60202 HTTP/1.1
> 
> 
< HTTP/1.1 201 Created
```


##### 3. Deploy UERANSIM (UE + gNB) Simulation via CLI

After validating that your 5G test subscribers have been provisioned successfully, you can proceed to deploy **UERANSIM** via script.

1. Make sure you are in the same `cli` directory:

```bash
cd aws-5gcloudlabs/scripts/cli
```

2. Run the script `ueransim-cli.sh`:

```bash
./ueransim-cli.sh

```

Expected Output. 

you should see output similar to: 

```bash
application.argoproj.io/free5gc-app created
```

###### Validate UERANSIM Deployment

After triggering the deployment, you can verify that the UE and gNB simulation components are running:
1. Verify using kubectl

Check that all Free5GC pods are starting correctly and reaching a Running status.


```bash
kubectl -n ueransim get pods
```

You should see the following pods in Running state:


kubectl -n ueransim get pods
NAME                                           READY   STATUS    RESTARTS  
aws-5gcloudlabs-ueransim-gnb-c4f64d998-5868p   2/2     Running   0    
aws-5gcloudlabs-ueransim-ue-5685b847d7-vhmn7   2/2     Running   0  




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


