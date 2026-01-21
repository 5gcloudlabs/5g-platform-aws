<h1 align="center">Welcome to aws-5GCloudLabs !</h1>
<p align="center">An open-source project for deploying 5G Core network pre-integrated with UE/RAN simulation environment on AWS.</p>
<p align="center">
<img width="600" height="3000" alt="main (2)" src="https://github.com/user-attachments/assets/09287ae6-25ef-4596-bacb-844dd08f2868" />
</p>

---

## Overview

Deploying a 5G Core network typically requires complex on-premise infrastructure, specialized hardware, and extensive manual configuration. **aws-5GCloudLabs** eliminates these barriers by providing a fully automated, cloud-native environment for deploying and testing the Free5GC 5G Core on Amazon EKS.

This project enables engineers, students, and practitioners to:
- **Experiment with 5G protocols** without physical infrastructure investment
- **Deploy reproducible environments** in minutes using Infrastructure-as-Code
- **Test end-to-end scenarios** with integrated UE and gNodeB simulation
- **Learn cloud-native networking** through production-grade tooling (GitOps, service mesh, observability)

Built with OpenTofu for infrastructure provisioning and Argo CD for GitOps-based application management, the entire stack follows declarative configuration principles for consistency and reproducibility.

---

## What You Get

- **Complete 5G Core**: Free5GC deployment with all network functions (AMF, SMF, UPF, UDM, PCF, etc.)
- **Integrated Testing**: UERANSIM pre-configured for immediate UE and gNB simulation
- **Production Patterns**: Service mesh (Istio), observability (Prometheus/Grafana/Loki), and automated TLS
- **Multi-interface Networking**: Multus CNI for 3GPP-compliant interface separation (N2, N3, N4, N6)
- **GitOps Workflow**: Declarative application lifecycle with Argo CD
- **One-command Deployment**: Automated infrastructure provisioning to running 5G lab

---

## Building Blocks

The **aws-5GCloudLabs** environment integrates infrastructure automation, Kubernetes orchestration, observability tooling, and 5G Core deployment into a cohesive, reproducible laboratory environment.

### Infrastructure Automation
- **OpenTofu** – Infrastructure-as-Code engine for declarative AWS resource provisioning

### AWS Services
- **VPC** – Network isolation with segmented subnets for infrastructure, Multus networks, and applications
- **EKS** – Managed Kubernetes cluster with custom node groups and kernel tuning for network workloads
- **EC2** – Compute instances with ENIs & security groups.
- **SSM** – Secure shell access and automation without SSH keys
- **EFS** – Persistent shared storage for MongoDB (UDR subscriber data and NRF profiles)
- **IAM / STS** – Fine-grained permissions with IRSA for pod-level AWS authentication
- **ACM** – TLS certificate management for secure service communication
- **S3** – Remote state storage for OpenTofu (must be preconfigured)

### Kubernetes Add-ons
- **Argo CD** – Application lifecycle management via GitOps.
- **AWS Load Balancer Controller** – Automatic ALB provisioning from Kubernetes Ingress resources
- **AWS EFS CSI Driver** – Dynamic EFS volume provisioning for stateful workloads
- **ExternalDNS** – Automatic DNS record management synchronized with Kubernetes services
- **cert-manager** – Automated TLS certificate issuance and renewal (Let's Encrypt integration)
- **Istio** – `Ingress Gateway` as reverse proxy & `Service-Mesh` capabilities for traffic management and observability. 
- **Multus CNI** – Multiple network interfaces per pod for 3GPP protocol compliance
- **Whereabouts IPAM** – Automatic IP address allocation for Multus secondary networks
- **Prometheus + Grafana + Loki** – Full observability stack for metrics, visualization, and log aggregation

### External Integrations
- **Let's Encrypt** – Public CA for automated certificate issuance via cert-manager
- **Cloudflare** – DNS provider for domain validation (requires registered domain)

### 5G Applications
- **Free5GC** – Open-source 5G Core network functions deployed via GitOps
- **UERANSIM** – Open-source gNodeB and UE simulator for registration and data session testing

---

## Architecture & Documentation

For detailed architecture diagrams, component interactions, and design decisions, see **[Architecture & Design](./docs/Arch&Design)**.

For step-by-step deployment instructions, prerequisites, and configuration options, see **[Installation Instructions](./installation-instructions)**.

---

## Quick Start
```bash
# 1. Configure AWS credentials and S3 backend
# 2. Clone the repository
git clone https://github.com/yourusername/aws-5gcloudlabs.git
cd aws-5gcloudlabs

# 3. Provision infrastructure
cd infrastructure
fill in the mandatory variables in `vars.auto.tfvars`
tofu init
tofu apply

# 4. Deploy 5G Core
# (Detailed steps in installation-instructions)
```

---

## Use Cases

- **5G Protocol Learning**: Hands-on experience with AMF, SMF, UPF, and other network functions
- **Cloud-Native Development**: Reference architecture for containerized telecom workloads
- **Integration Testing**: Validate UE registration, PDU sessions, and data plane connectivity
- **Research & Experimentation**: Modify core configurations, test edge computing scenarios, network slicing

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

---

## License

[LICENSE](./LICENSE)

---

## Acknowledgments

This project builds on the excellent work of:
- [Free5GC](https://free5gc.org/) - Open-source 5G Core implementation
- [UERANSIM](https://github.com/aligungr/UERANSIM) - 5G UE and RAN simulator
- The broader cloud-native and telecom open-source communities

---
