# free5GC AMF Helm Chart

This chart deploys the **Access and Mobility Management Function (AMF)**, a core control-plane network function in a 5G Standalone (SA) network.  

The AMF is responsible for:  
- Registration management  
- Connection and reachability management  
- Mobility and handover control  
- Routing signaling messages between the UE and the 5GC  

---

## 🔧 Customizations in this Chart

Compared to the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) chart, this version includes the following modifications:  

- Updated container images from `towards5gs/*` to `<your-registry>/free5gc-amf`  
- Changed default `values.yaml` to align with CNAD LTD’s 5G Cloud Labs environment  
- Default `global.amf.service.ngap.enabled = true` to use a Kubernetes Service instead of Multus for N2  
- Simplified initContainer logic for NRF readiness  

👉 See [values.yaml](./values.yaml) for full parameter details.  

---

## 📖 References

- [free5GC project](https://github.com/free5gc/free5gc)  
- [3GPP TS 23.501](https://www.3gpp.org/DynaReport/23501.htm) – 5G System Architecture  
- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm)  

---

## ⚖️ License & Attribution

This chart is based on **towards5gs-helm** (Apache 2.0).  
Modifications and integrations are © 2025 CNAD LTD.
