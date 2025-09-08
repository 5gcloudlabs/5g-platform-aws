# Executor Helm Chart

## Purpose

This Helm chart deploys the **Executor** pod on Amazon EKS.  

The Executor pod is responsible for executing deployment scripts and handling provisioning workflows triggered by the Console UI.  

---

## Overview

The Executor acts as the backend execution engine for the 5G Cloud Labs environment:  

- Runs automation scripts for deploying the **5G Core Network** ([free5GC](https://github.com/free5gc/free5gc)) components.  
- Handles provisioning of **subscribers** and integration with the Console UI.  
- Deploys network simulations (e.g., gNB and UE via [UERANSIM](https://github.com/aligungr/UERANSIM)) when triggered from the UI.  
- Provides a controlled runtime environment inside the cluster to keep deployment logic separate from the UI frontend.  

---

## Deployment

- This chart is deployed and managed via Argo CD.
- The corresponding Argo CD Application manifest is defined in
  [`executor-app.yml`](../../argocd/required-apps/executor-app.yml).
- The application manifest is included in the "required-apps" set and is deployed automatically by Argo CD post EKS cluster creation.
- The pod runs the container image 

---

## References



---

## License & Attribution

This chart was created and is maintained by © 2025 5g-cloud-labs (a project by CNAD LTD.).
<br>Licensed under the Apache License 2.0.
