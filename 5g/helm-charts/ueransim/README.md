# UERANSIM Helm chart

Part of **5G Platform AWS** — RAN and UE simulation for end-to-end evaluation within the AWS platform environment.

## Purpose
This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys UERANSIM components on a public cloud environment, specifically optimized for Amazon EKS.  
It organizes the UERANSIM components as subcharts (`gnb` and `ue`) and manages their configuration for deployment and integration with the free5GC 5G Core.

---

## Overview
The UERANSIM Helm chart provides a complete simulation of a 5G Radio Access Network (gNB) and User Equipment (UE), enabling realistic testing of 5G Core deployments.  
It includes the following subcharts:

- [gnb](./templates/gnb) – Simulates a 5G base station (gNB) that connects to the free5GC Core.  
- [ue](./templates/ue) – Simulates User Equipment (UE) devices that register, establish sessions, and exchange traffic with the Core via the gNB.  

<img width="2412" height="1519" alt="5G Core_ueransim" src="https://github.com/user-attachments/assets/05729a55-c26d-4e45-b48c-8570e8c1ee97" />

---

## Customizations in this Chart
This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project. Both subcharts, together with the top-level `values.yaml`, have been customized to integrate UERANSIM with the free5GC Core and enable deployment on Amazon EKS.

Customizations can be found in:

- [`gnb-configmap.yaml`](./templates/gnb/gnb-configmap.yaml)
- [`gnb-deployment.yaml`](./templates/gnb/gnb-deployment.yaml)
- [`gnb-n2-nad.yaml`](./templates/gnb/gnb-n2-nad.yaml)
- [`gnb-n3-nad.yaml`](./templates/gnb/gnb-n3-nad.yaml)
- [`ue-configmap.yaml`](./templates/ue/ue-configmap.yaml)
- [`ue-deployment.yaml`](./templates/ue/ue-deployment.yaml)
- [`ueransim global values.yaml`](./values.yaml)
  
---

## Deployment

Deployed on demand via the Network Deployment Agent at `https://console.<domain>` or as the final step of an Argo Workflow (`sub-prov-ueransim-wf`, `5g-solution-wf`).

The agent applies the Argo CD Application wrapper at `5g/argocd-apps/ueransim-app/` with MCC, MNC, and subscriber count. See the [Network deployment guide](../../../docs/installation-instructions/01%20network-deployment.md).

---

## References
- [UERANSIM](https://github.com/aligungr/UERANSIM) – Open-source 5G RAN and UE simulator  
- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) – Helm charts for free5GC and UERANSIM (reference project)

---

## License & Attribution
This chart is based on upstream projects licensed under Apache 2.0.  
Customizations and integrations are owned by © 5G Cloud Labs.

