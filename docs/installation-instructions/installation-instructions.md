
## Installation Instructions

### 1. Prerequisites

#### 1. a) Cloud Account Requirements

Before deploying any infrastructure, these must be available:

| Requirement | Description |
|------------|-------------|
| **AWS Account** | With permissions to create the required **AWS services** as described in the [AWS Services](#aws-services) section. |
| **Cloudflare Account** | With a **registered domain** + **API Token** with respective domain zone "DNS:Edit" permissions. |


#### 1. b) Local Workstation Requirements
Install the following tools locally:

| Tool | Installation |
|------|--------------|
| **AWS CLI** | [Install guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| **OpenTofu** | [Install guide](https://opentofu.org/docs/intro/install/) |
| **kubectl** | [Install guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/) |
| **Helm** (optional) | [Install guide](https://helm.sh/docs/intro/install/) |


Verify installs & versions

Run the following to confirm tools are installed:
```bash
aws --version
tofu version
kubectl version --client --short
helm version --short
argocd --version   
```

#### 1. c) Configure AWS credentials

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


#### 1. d) Create an S3 Bucket for the OpenTofu State

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

### 3. Set OpenTofu Input Variables

**Navigate to the infrastructure directory:** 

```bash
cd aws-5gcloudlabs/infrastructure
```
**Update the values of the variables in vars.auto.tfvars:**
```bash
nano vars.auto.tfvars
```

| Variable Name | Default Value | Description |
|--------------|--------------|-------------|
| `region` | `eu-central-1` | AWS region where all infrastructure resources will be created. |
| `bucket-name` | — | Name of the S3 bucket used to store the Terraform remote state file. |
| `key` | — | Path and filename of the Terraform state file inside the S3 bucket. |
| `vpc_name` | `cloud-5g-vpc` | Name assigned to the VPC hosting the 5G Core infrastructure. |
| `vpc_cidr` | `192.168.0.0/16` | Primary CIDR block for the VPC network. |
| `azs` | `["eu-central-1b", "eu-central-1c"]` | Availability Zones used for creating subnets and high availability. |
| `eks_cluster_name` | `cloud-5g-eks` | Name of the Amazon EKS cluster running the 5G Core workloads. |
| `ami_id` | `ami-064c2479baf726e71` | Ubuntu-based AMI optimized for EKS worker nodes and Free5GC compatibility. |
| `domain_name` | — | Public domain name associated with the DNS hosted zone. |
| `zone_id` | — | Identifier of the DNS hosted zone at the DNS provider. |
| `cloudflare_api_token` | — | API token used by Terraform and ExternalDNS to manage DNS records in Cloudflare. |


After completing all prerequisites, you can deploy the AWS infrastructure and the Kubernetes add-ons using **OpenTofu**.

### 4. Install Infrastructure Using OpenTofu

Infrastructure deployment is performed in two stages: a targeted apply provisions the EKS cluster, worker nodes, and their direct dependencies (such as the VPC) to establish the Kubernetes environment, followed by a full `tofu apply` to deploy the remaining infrastructure components, including those that depend on EKS.

#### 4. a) Initialize OpenTofu Infrastructure Directory

Navigate to the infrastructure directory:

```bash
cd aws-5gcloudlabs/infrastructure
```
Initialize infrastructure directory:
```bash
/aws-5gcloudlabs/infrastructure$ tofu init
```

Expected Output:
```bash
...
```

#### 4. b) Create targetted execution plan/execution:

**Execution Plan**

```bash
/aws-5gcloudlabs/infrastructure$ tofu plan --target=module.eks
```
Expected Output:
```bash
Plan: 68 to add, 0 to change, 0 to destroy.
```

**Execution:**

```bash
/aws-5gcloudlabs/infrastructure$ tofu apply

Plan: 68 to add, 0 to change, 0 to destroy.


Do you want to perform these actions?
  OpenTofu will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

```
Expected Output:
```bash
Apply complete! Resources: 68 added, 0 changed, 0 destroyed.
```


#### 4. c) Create final execution plan/execution:

**Execution Plan**

```bash
/aws-5gcloudlabs/infrastructure$ tofu plan
```
Expected Output:
```bash
Plan: 110 to add, 0 to change, 0 to destroy.
```

**Execution:**

```bash
/aws-5gcloudlabs/infrastructure$ tofu apply

Plan: 110 to add, 0 to change, 0 to destroy.


Do you want to perform these actions?
  OpenTofu will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

```
Expected Output:
```bash
Apply complete! Resources: 110 added, 0 changed, 0 destroyed.
```

**Summary**

The OpenTofu configuration performs the following:

Provisions all AWS resources (VPC, EKS, EC2, EFS, TLS Certificate, IAM roles, etc.).

Deploys several Kubernetes add-ons directly using helm_release resources.

Applies the Argo CD required-apps Application using a kubectl_manifest resource, which triggers Argo CD to fetch all remaining add-ons from the Git repository.


#### 4. d) Validate infrastructure creation
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


**Monitoring & Observability stack:**

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

#### B) Deployment via Console-UI

You can deploy the 5G Core using the AWS 5G Cloud Labs Web Console, which provides an interactive UI for entering MCC/MNC values and triggering the deployment pipeline.

Steps

- Open the Console UI in your browser:

```bash
https://console.<your-domain>
```

- Insert MCC & MNC values and click Deploy:
<img width="1295" height="692" alt="console-1" src="https://github.com/user-attachments/assets/9e8ed1d3-e85c-452a-ac1a-1d962d3f5bc5" />

- Wait for parameters to be updated accordingly:
<img width="1295" height="692" alt="console-2" src="https://github.com/user-attachments/assets/b8fc3d4c-faec-4d56-98e9-e8acdb8f35f7" />


- Check the state of 5G Core CNFs:
<img width="1295" height="692" alt="console-3" src="https://github.com/user-attachments/assets/95644f1d-8c0a-4b95-87dd-3a947a68e341" />


- Insert the number of subscribers to provision:
<img width="1295" height="692" alt="console-4" src="https://github.com/user-attachments/assets/935b68b7-ade7-4629-b421-e7255ce1b3d3" />

- Wait until provisioning is complete:
<img width="1295" height="692" alt="console-5" src="https://github.com/user-attachments/assets/affd71f8-5330-4880-b64a-231f40d1e26d" />


- After subscriber provisioning is complete, click on Proceed to deploy simulation:
<img width="1295" height="692" alt="console-6" src="https://github.com/user-attachments/assets/90ab6ab0-7cd1-4abb-90c7-aec568d89b1c" />


- Click on Deploy UERANSIM:
<img width="1295" height="692" alt="console-7" src="https://github.com/user-attachments/assets/728ff9fc-9999-409a-b320-1920ea7a91dd" />


- Check the state of UERANSIM and click on Launch Network Validation when ready:
<img width="1295" height="692" alt="console-8" src="https://github.com/user-attachments/assets/14d7d50b-329b-4bbc-906a-16a2392d3942" />


- Click on UE Registration Dashboard:
<img width="1295" height="692" alt="console-9" src="https://github.com/user-attachments/assets/8ce66be3-fbc5-462a-b286-e3e8535f7e37" />


- Number of successful UE Registraions:
<img width="1295" height="684" alt="reg" src="https://github.com/user-attachments/assets/7ec43625-5058-4230-b0cd-dad4341f6531" />



### 7. System Monitoring via Grafana



### 8. Termination Procedure
