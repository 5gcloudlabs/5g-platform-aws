# free5GC NSSF Helm Chart

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Network Slice Selection Function (NSSF) on a public cloud environment, specifically optimized for Amazon EKS.

The NSSF is a core control-plane network function in a 5G Standalone (SA) network and is responsible for:

- Selecting the appropriate network slice for a UE based on subscription and policy  
- Providing slice information to other network functions (e.g., AMF)  
- Supporting slice-aware session management and routing decisions  

---

## Customizations in this Chart

This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project.  
The primary customizations focus on networking configuration to enable deployment on public cloud, namely Amazon EKS.  

Customizations can be found in:  
- [`templates/`](./templates/)  
- [`values.yaml`](./values.yaml)  

---

## References

- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) – Helm charts for deploying free5GC on Kubernetes.  
- [free5GC](https://github.com/free5gc/free5gc) – Open-source implementation of the 5G Core network functions.  
  


---

## License & Attribution

This chart is based on **towards5gs-helm** (Apache 2.0).  
Modifications and integrations are owned by © 2025 5g-cloud-labs (a project by CNAD LTD.).
