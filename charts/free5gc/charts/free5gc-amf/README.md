# free5GC AMF Helm Chart

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Access and Mobility Management Function (AMF) on a public cloud environment, specifically optimized for Amazon EKS.  

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
- [`amf-deployment.yaml`](./templates/amf-deployment.yaml)
- [`AMF values file`](./values.yaml)  
- [`free5GC global values file`](../../values.yaml)  

---

## References

- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) – Helm charts for deploying free5GC on Kubernetes.  
- [free5GC](https://github.com/free5gc/free5gc) – Open-source implementation of the 5G Core network functions.  
  


---

## License & Attribution

This chart is based on **towards5gs-helm** (Apache 2.0).  
Modifications and integrations are owned by © 2025 5g-cloud-labs (a project by CNAD LTD.).
