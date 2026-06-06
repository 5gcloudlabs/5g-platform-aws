# free5GC UDM Helm Chart

## Purpose

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Unified Data Management (UDM) function on a public cloud environment, specifically optimized for Amazon EKS.

---

## Overview

The UDM is a core control-plane network function in a 5G Standalone (SA) network and is responsible for:
- Storing and managing subscriber profile and authentication data  
- Supporting authentication and authorization procedures  
- Serving as the primary data source for AUSF and other network functions
  
<img width="2412" height="1519" alt="5G Core_udm" src="https://github.com/user-attachments/assets/d89a218b-e8ae-43e5-87ce-c6befc338028" />

---

## Customizations in this Chart

This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, to enable deployment on Amazon EKS. 

Customizations can be found in:  
- [`udm-deployment.yaml`](./templates/udm-deployment.yaml)
- [`UDM values.yaml`](./values.yaml)

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
