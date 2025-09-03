# Executor Helm Chart

This Helm chart deploys the **Executor** component of the [aws-5gcloudlabs](https://github.com/5g-cloud-labs/aws-5gcloudlabs) project on Amazon EKS.  

The Executor runs inside the Kubernetes cluster and is responsible for executing deployment scripts and handling provisioning workflows triggered by the Console UI.  

---

## Overview

The Executor acts as the backend execution engine for the 5G Cloud Labs environment:  

- Runs automation scripts for deploying the **5G Core Network** ([free5GC](https://github.com/free5gc/free5gc)) components.  
- Handles provisioning of **subscribers** and integration with the Console UI.  
- Deploys network simulations (e.g., gNB and UE via [UERANSIM](https://github.com/aligungr/UERANSIM)) when triggered from the UI.  
- Provides a controlled runtime environment inside the cluster to keep deployment logic separate from the UI frontend.  

---

## Deployment

The Executor is packaged as a Docker container and deployed on Amazon EKS via this Helm chart. It is managed as an Argo CD Application, enabling GitOps-based deployment and lifecycle management.
