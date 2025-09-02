# free5GC PCF Helm Chart

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Policy Control Function (PCF) on a public cloud environment, specifically optimized for Amazon EKS.

The PCF is a core control-plane network function in a 5G Standalone (SA) network and is responsible for:

- Providing policy rules for session management and QoS  
- Enforcing charging and access policies for UEs  
- Communicating with SMF and other network functions to maintain compliance with operator policies  

---

## Customizations in this Chart
This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, to enable deployment on Amazon EKS. 

Customizations can be found in:  
- [`pcf-configmap.yaml`](./templates/pcf-configmap.yaml)
- [`pcf-deployment.yaml`](./templates/pcf-deployment.yaml)
- [`PCF values.yaml`](./values.yaml)  

---

## References

- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) – Helm charts for deploying free5GC on Kubernetes.  
- [free5GC](https://github.com/free5gc/free5gc) – Open-source implementation of the 5G Core network functions.  
  


---

## License & Attribution

This chart is based on **towards5gs-helm** (Apache 2.0).  
Modifications and integrations are owned by © 2025 5g-cloud-labs (a project by CNAD LTD.).
