# free5GC SMF Helm Chart

## Purpose

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Session Management Function (SMF) on a public cloud environment, specifically optimized for Amazon EKS.

---
## Overview

The SMF is a core control-plane network function in a 5G Standalone (SA) network and is responsible for:
- Session management for PDU sessions of UEs  
- Allocating and managing IP addresses for UEs  
- Interfacing with UPF for traffic forwarding and QoS enforcement
<img width="2412" height="1519" alt="5G Core_smf" src="https://github.com/user-attachments/assets/38a9ae3f-8adc-41e5-801f-10200a57df69" />

---

## Customizations in this Chart

This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project.  
The primary customizations focus on networking configuration to enable deployment on Amazon EKS.  

Customizations can be found in:  
- [`smf-configmap.yaml`](./templates/smf-configmap.yaml)
- [`smf-deployment.yaml`](./templates/smf-deployment.yaml)
- [`smf-n4-nad.yaml`](./templates/smf-n4-nad.yaml)
- [`SMF values.yaml`](./values.yaml)  
- [`free5GC global values.yaml`](../../values.yaml)   


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
