# free5GC UDR Helm Chart

## Purpose

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Unified Data Repository (UDR) on a public cloud environment, specifically optimized for Amazon EKS.

---

## Overview

The UDR is a core control-plane network function in a 5G Standalone (SA) network and is responsible for:
- Storing subscription data, policies, and other user-related information  
- Providing data to UDM, PCF, and other network functions  
- Supporting database queries in accordance with 3GPP-defined interfaces

<img width="2412" height="1519" alt="5G Core_udr" src="https://github.com/user-attachments/assets/b45d3764-d0e5-4817-bbc9-e08c17ae1f08" />

---

## Customizations in this Chart

This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, to enable deployment on Amazon EKS.

Customizations can be found in:  
- [`udr-deployment.yaml`](./templates/udr-deployment.yaml)
- [`UDR values.yaml`](./values.yaml)  

---

## Deployment

Deployment is managed via Argo CD Application [`free5gc-app.base`](../../../../argocd/free5gc-app/free5gc-app.base).

---

## References

- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) – Helm charts for deploying free5GC on Kubernetes.  
- [free5GC](https://github.com/free5gc/free5gc) – Open-source implementation of the 5G Core network functions.  
  
---

## License & Attribution

This chart is based on **towards5gs-helm** (Apache 2.0).  
Modifications and integrations are owned by © 2025 5g-cloud-labs (a project by CNAD LTD.).
