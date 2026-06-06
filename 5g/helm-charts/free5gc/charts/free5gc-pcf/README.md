# free5GC PCF Helm Chart

## Purpose

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Policy Control Function (PCF) on a public cloud environment, specifically optimized for Amazon EKS.

---

## Overview

The PCF is a core control-plane network function in a 5G Standalone (SA) network and is responsible for:
- Providing policy rules for session management and QoS  
- Enforcing charging and access policies for UEs  
- Communicating with SMF and other network functions to maintain compliance with operator policies  
<img width="2412" height="1519" alt="5G Core_pcf" src="https://github.com/user-attachments/assets/daedbd54-194b-4b37-8bb2-08fcd69b9837" />

---

## Customizations in this Chart
This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, to enable deployment on Amazon EKS. 

Customizations can be found in:  
- [`pcf-deployment.yaml`](./templates/pcf-deployment.yaml)
- [`PCF values.yaml`](./values.yaml)  

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
