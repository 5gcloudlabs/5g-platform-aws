# free5GC AMF Helm Chart

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) Access and Mobility Management Function (AMF) on a public cloud environment, specifically optimized for Amazon EKS. It provides the core control-plane functionality in a 5G Standalone (SA) network.  

The AMF is responsible for:  
- Registration management  
- Connection and reachability management  
- Mobility and handover control  
- Routing signaling messages between the UE and the 5GC  

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

- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm)  
- [free5GC project](https://github.com/free5gc/free5gc)  
- [3GPP TS 23.501](https://www.3gpp.org/DynaReport/23501.htm) – 5G System Architecture  

---

## License & Attribution

This chart is based on **towards5gs-helm** (Apache 2.0).  
Modifications and integrations are owned by © 2025 5g-cloud-labs (a project by CNAD LTD.).
