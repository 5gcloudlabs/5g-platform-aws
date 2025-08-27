# free5GC AMF Helm Chart

This chart deploys the **Access and Mobility Management Function (AMF)**, a core control-plane network function in a 5G Standalone (SA) network.  

The AMF is responsible for:  
- Registration management  
- Connection and reachability management  
- Mobility and handover control  
- Routing signaling messages between the UE and the 5GC  

---

## 🔧 Customizations in this Chart

This chart has been adapted from the upstream towards5gs-helm project.
The primary customizations focus on networking configuration to enable deployment on Amazon EKS in the public cloud.

Customizations can be found in:

./templates/
[values.yaml](./values.yaml)
../../values.yaml

 for full parameter details.  

---

## 📖 References

- [free5GC project](https://github.com/free5gc/free5gc)  
- [3GPP TS 23.501](https://www.3gpp.org/DynaReport/23501.htm) – 5G System Architecture  
- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm)  

---

## ⚖️ License & Attribution

This chart is based on **towards5gs-helm** (Apache 2.0).  
Modifications and integrations are © 2025 CNAD LTD.
