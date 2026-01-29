
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

### 4. Provision Infrastructure Using OpenTofu

OpenTofu provisions the required AWS infrastructure and triggers cluster-bootsrap via ArgoCD.

#### 4. a) Initialize configuration

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

Initializing the backend...

Successfully configured the backend "s3"! OpenTofu will automatically
use this backend unless the backend configuration changes.
Initializing modules...
.
.
.
Initializing provider plugins...
.
.
.
OpenTofu has been successfully initialized!

You may now begin working with OpenTofu. Try running "tofu plan" to see
any changes that are required for your infrastructure. All OpenTofu commands
should now work.
```

#### 4. b) Create a plan:


```bash
/aws-5gcloudlabs/infrastructure$ tofu plan 
```
Expected Output:
```bash
.
.
.
Plan: 144 to add, 0 to change, 0 to destroy.
```

**Execution:**

```bash
/aws-5gcloudlabs/infrastructure$ tofu apply

Plan: 144 to add, 0 to change, 0 to destroy.


Do you want to perform these actions?
  OpenTofu will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

```
Expected Output:
```bash
.
.
.
Apply complete! Resources: 144 added, 0 changed, 0 destroyed.
```


#### 4. c) Apply configuration


```bash
/aws-5gcloudlabs/infrastructure$ tofu plan
```
Expected Output:
```bash
Plan: 144 to add, 0 to change, 0 to destroy.
```

**Execution:**

```bash
/aws-5gcloudlabs/infrastructure$ tofu apply

Plan: 144 to add, 0 to change, 0 to destroy.


Do you want to perform these actions?
  OpenTofu will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

```
Expected Output:
```bash
.
.
.
Apply complete! Resources: 144 added, 0 changed, 0 destroyed.
```

**Summary**

The OpenTofu configuration performs the following:

- Provisions the required AWS resources [ VPC subnets, IGW, NATGW, EKS cluster, worker nodes, additional network interfaces, SGs, SG rules, EFS, TLS Certificate, IAM roles, etc.).

- Installs Argocd helm chart, via helm_release resource.

- Cluster bootstrapping by applying the Argo CD required-apps app-of-apps using a kubectl_manifest resource, triggering ArgoCD to deploy all the required applications for the EKS cluster, from the github repository.


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



##### - Verify EKS Cluster Bootstrapping:
Confirm that Argo CD has successfully deployed the `cluster-bootstrap` Application and all child applications.
The status should display **Synced*** and **Healthy**:



```bash
kubectl -n argocd get app 
NAME                           SYNC STATUS   HEALTH STATUS
aws-efs-csi-driver             Synced        Healthy
aws-load-balancer-controller   Synced        Healthy
cert-manager                   Synced        Healthy
cert-manager-certificate       Synced        Healthy
cert-manager-cluster-issuer    Synced        Healthy
cloudflare-token-secret        Synced        Healthy
cluster-bootstrap              Synced        Healthy
console-ui                     Synced        Healthy
curl                           Synced        Healthy
executor                       Synced        Healthy
external-dns                   Synced        Healthy
free5gc                        Synced        Healthy
gateway                        Synced        Healthy
ingress                        Synced        Healthy
istio-base                     Synced        Healthy
istio-gateway                  Synced        Healthy
istiod                         Synced        Healthy
kube-prometheus-stack          Synced        Healthy
kube-prometheus-stack-crds     Synced        Healthy
loki                           Synced        Healthy
multus                         Synced        Healthy
storage-class                  Synced        Healthy
virtual-services               OutOfSync     Healthy
whereabouts                    Synced        Healthy


*virual-services 


##### - Ensure the respective pods are deployed successfully


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
