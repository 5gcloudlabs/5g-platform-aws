# free5GC AMF Helm Chart

## Purpose

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Access and Mobility Management Function (AMF) on a public cloud environment, specifically optimized for Amazon EKS.  

---

## Overview
<img width="2412" height="1519" alt="5G Core_AMF_1" src="https://github.com/user-attachments/assets/4c39a48a-b577-491b-bdbe-ee48fc4a820b" />
The AMF provides the core control-plane functionality in a 5G Standalone (SA) network and is responsible for:  
- Registration management  
- Connection and reachability management  
- Mobility and handover control  
- Routing signaling messages between the UE and the 5GC  

---

## Customizations in this Chart

This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project.  
The primary customizations focus on networking configuration to enable deployment on Amazon EKS.  

Customizations can be found in:  
- [`amf-configmap.yaml`](./templates/amf-configmap.yaml)
- [`amf-deployment.yaml`](./templates/amf-deployment.yaml)
- [`amf-n2-nad.yaml`](./templates/amf-n2-nad.yaml)
- [`AMF values.yaml`](./values.yaml)  
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
