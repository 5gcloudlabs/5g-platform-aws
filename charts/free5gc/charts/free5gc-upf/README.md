# free5GC UPF Helm Chart

This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the [free5GC](https://github.com/free5gc/free5gc) User Plane Function (UPF) on a public cloud environment, specifically optimized for Amazon EKS.

The UPF is a core user-plane network function in a 5G Standalone (SA) network and is responsible for:

- Forwarding user-plane traffic between RAN and data networks  
- Applying QoS policies and traffic shaping  
- Supporting PDU session management in coordination with SMF  

---

## Customizations in this Chart

This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project.  
The primary customizations focus on networking configuration to enable deployment on Amazon EKS.  

Customizations can be found in:  
- [`upf-configmap.yaml`](./templates/upf-configmap.yaml)
- [`upf-deployment.yaml`](./templates/upf-deployment.yaml)
- [`upf-n3-nad.yaml`](./templates/upf-n3-nad.yaml)
- [`upf-n4-nad.yaml`](./templates/upf-n4-nad.yaml)
- [`upf-n6-nad.yaml`](./templates/upf-n6-nad.yaml)
- [`UPF values.yaml`](./values.yaml)  
- [`free5GC global values.yaml`](../../values.yaml)  

---

## References

- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) – Helm charts for deploying free5GC on Kubernetes.  
- [free5GC](https://github.com/free5gc/free5gc) – Open-source implementation of the 5G Core network functions.  
  


---

## License & Attribution

This chart is based on **towards5gs-helm** (Apache 2.0).  
Modifications and integrations are owned by © 2025 5g-cloud-labs (a project by CNAD LTD.).
