# free5GC UDR Helm Chart

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Unified Data Repository (UDR) on a public cloud environment, specifically optimized for Amazon EKS.

The UDR is a core control-plane network function in a 5G Standalone (SA) network and is responsible for:

- Storing subscription data, policies, and other user-related information  
- Providing data to UDM, PCF, and other network functions  
- Supporting database queries in accordance with 3GPP-defined interfaces  

---

## Customizations in this Chart

This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project.  
The primary customizations focus on networking configuration to enable deployment on public cloud, namely Amazon EKS.  

Customizations can be found in:  
- [`templates/`](./templates/)  
- [`values.yaml`](./values.yaml)  
- [`global values.yaml`](../../values.yaml)  

---

## References

- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) – Helm charts for deploying free5GC on Kubernetes.  
- [free5GC](https://github.com/free5gc/free5gc) – Open-source implementation of the 5G Core network functions.  
  


---

## License & Attribution

This chart is based on **towards5gs-helm** (Apache 2.0).  
Modifications and integrations are owned by © 2025 5g-cloud-labs (a project by CNAD LTD.).
