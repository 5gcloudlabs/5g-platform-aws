# Infrastructure

This directory defines and provisions all the underlying **AWS** and **Kubernetes** infrastructure components required for the **AWS 5G Cloud Labs** environment.  
All infrastructure is deployed using **OpenTofu** — an open-source Infrastructure as Code (IaC) tool fully compatible with Terraform syntax.

---

## AWS Resources

These files define the core AWS infrastructure for hosting the EKS-based 5G environment.

| File | Description |
|------|--------------|
| `aws_vpc.tf` | Creates the main Virtual Private Cloud (VPC) with subnets, route tables, and gateways. |
| `aws_vpc_multus-subnet.tf` | Adds dedicated subnets for Multus CNI network interfaces. |
| `aws_vpc_n6-routing.tf` | Configures N6 interface routing for UPF traffic. |
| `aws_eks.tf` | Provisions the Amazon Elastic Kubernetes Service (EKS) cluster. |
| `aws_ec2_istio_sg-rule.tf` | Defines EC2 security group rules for Istio ingress and egress traffic. |
| `aws_ec2_multus-sg.tf` | Creates security groups for Multus ENI interfaces. |
| `aws_ec2_multus-eni.tf` | Manages secondary ENI attachment for Multus CNI. |
| `aws_ec2_multus-sg-rule.tf` | Defines specific ingress and egress rules for Multus interfaces. |
| `aws_efs.tf` | Creates an Amazon EFS File System for persistent storage. |
| `aws_iam_efs.tf` | Defines IAM policies and roles for the EFS CSI Driver. |
| `aws_iam_alb-controller.tf` | Configures IAM roles and policies for the AWS Load Balancer Controller. |
| `aws_acm+dns_valid.tf` | Manages ACM certificates and DNS validation for HTTPS. |
| `aws_ssm_doc-5gcp.tf` | Defines SSM documents for 5G Core provisioning automation. |
| `aws_ssm_doc-5gup.tf` | Defines SSM documents for 5G User Plane provisioning automation. |

---

## Kubernetes Resources

These files configure Kubernetes objects deployed into the EKS cluster.

| File | Description |
|------|--------------|
| `k8s_namespaces.tf` | Creates required namespaces (e.g., `argocd`, `free5gc`, `ueransim`). |
| `k8s_ingress.tf` | Defines ingress configurations for external access. |
| `k8s_istio_resources.tf` | Configures Istio Gateway and VirtualService resources. |
| `k8s_cert-manager_resources.tf` | Defines ClusterIssuer and Certificate resources for TLS. |
| `k8s_cloudflare-api-token-secret.tf` | Creates the Cloudflare API token secret for DNS management. |
| `k8s_cloudflare-api-token-secret-cert-manager-ns.tf` | Replicates the Cloudflare token in the `cert-manager` namespace. |
| `k8s_cm_domain_name.tf` | Configures a ConfigMap containing the cluster’s domain name. |
| `k8s_cm_grafana_pdu_dashboard.tf` | Loads a Grafana dashboard for PDU session monitoring. |
| `k8s_cm_grafana_reg_dashboard.tf` | Loads a Grafana dashboard for registration metrics. |
| `k8s_git-repo-secret.tf` | Creates a Git credential secret for Argo CD. |
| `k8s_git-repo-secret_def_ns.tf` | Adds the same secret to the default namespace. |
| `k8s_env_variable_vpc-cni.tf` | Configures environment variables for the AWS VPC CNI plugin. |
| `k8s_storage_class.tf` | Defines the `efs-sc` StorageClass for dynamic EFS-backed Persistent Volumes. |

---

## Helm Releases

These files deploy critical cluster add-ons via Helm charts.

| File | Description |
|------|--------------|
| `helm_argocd.tf` | Installs Argo CD for GitOps-based deployment management. |
| `helm_cert-manager.tf` | Deploys Cert-Manager for automatic certificate management. |
| `helm_efs_csi_driver.tf` | Installs the Amazon EFS CSI Driver to support dynamic PV provisioning. |
| `helm_istio-charts.tf` | Deploys Istio service mesh components. |
| `helm_external-dns-cloudflare.tf` | Installs ExternalDNS configured for Cloudflare DNS records. |
| `helm_alb-controller.tf` | Installs the AWS Load Balancer Controller for ingress handling. |

---

## Supporting Files

| File | Description |
|------|--------------|
| `argocd_required_apps.tf` | Ensures core Argo CD Applications (e.g., Executor, Console UI) are pre-registered. |
| `provider.tf` | Defines provider configurations (AWS, Kubernetes, Helm). |
| `variable.tf` | Declares reusable variables for the infrastructure stack. |
| `terraform.tfvars` | Contains environment-specific variable values. |

---
