# free5GC NRF Helm Chart

## Purpose

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Network Repository Function (NRF) on a public cloud environment, specifically optimized for Amazon EKS.

---

## Overview

The NRF is a core control-plane network function in a 5G Standalone (SA) network and is responsible for:
- Maintaining the Network Function (NF) registration and discovery database  
- Supporting service discovery for other 5GC network functions  
- Facilitating interactions between network functions via the Service-Based Architecture (SBA)  

<img width="2412" height="1519" alt="5G Core_nrf" src="https://github.com/user-attachments/assets/a4164841-3bae-4049-aff1-d4cee58a34e5" />

---

## Customizations in this Chart

This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, to enable deployment on Amazon EKS.

Customizations can be found in:  
- [`nrf-deployment.yaml`](./templates/nrf-deployment.yaml)
- [`NRF values.yaml`](./values.yaml)  

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
