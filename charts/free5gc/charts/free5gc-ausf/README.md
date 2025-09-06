# free5GC AUSF Helm Chart


## Purpose

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Authentication Server Function (AUSF) on a public cloud environment, specifically optimized for Amazon EKS.  

## Overview

The AUSF is a core control-plane network function in a 5G Standalone (SA) network and is responsible for:  
- Authentication of User Equipment (UE)  
- Supporting primary authentication procedures with the Unified Data Management (UDM)  
- Delivering authentication results to other 5GC network functions  


## Customizations in this Chart

This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, to enable deployment on Amazon EKS.

Customizations can be found in:  
- [`ausf-configmap.yaml`](./templates/ausf-configmap.yaml)
- [`ausf-deployment.yaml`](./templates/ausf-deployment.yaml)
- [`AUSF values.yaml`](./values.yaml)   


## Deployment

Deployment is managed via Argo CD Application [`free5gc-app.base`](../../../../argocd/free5gc-app/free5gc-app.base).


## References

- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) – Helm charts for deploying free5GC on Kubernetes.  
- [free5GC](https://github.com/free5gc/free5gc) – Open-source implementation of the 5G Core network functions.  
  



## License & Attribution

This chart is based on **towards5gs-helm** (Apache 2.0).  
Modifications and integrations are owned by © 2025 5g-cloud-labs (a project by CNAD LTD.).
