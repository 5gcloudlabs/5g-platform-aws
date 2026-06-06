# free5GC NSSF Helm Chart

## Purpose

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Network Slice Selection Function (NSSF) on a public cloud environment, specifically optimized for Amazon EKS.

---

## Overview

The NSSF is a core control-plane network function in a 5G Standalone (SA) network and is responsible for:
- Selecting the appropriate network slice for a UE based on subscription and policy  
- Providing slice information to other network functions (e.g., AMF)  
- Supporting slice-aware session management and routing decisions
  
<img width="2412" height="1519" alt="5G Core_nssf" src="https://github.com/user-attachments/assets/f0be22b8-5f61-4736-bf4a-adaad8cedca3" />

---

## Customizations in this Chart

This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, to enable deployment on Amazon EKS.

Customizations can be found in:  
- [`nssf-configmap.yaml`](./templates/nssf-configmap.yaml)
- [`nssf-deployment.yaml`](./templates/nssf-deployment.yaml)
- [`NSSF values.yaml`](./values.yaml)   

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
Modifications and integrations are owned by © 5G Cloud Labs.
