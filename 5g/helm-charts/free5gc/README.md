# free5gc Helm chart

Part of **5G Platform AWS** — Free5GC 5G Core for end-to-end evaluation within the AWS platform environment.

## Purpose
This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the complete free5GC 5G Core network on a public cloud environment, specifically optimized for Amazon EKS.  
It organizes all free5GC network functions as subcharts and manages their configuration for deployment.

---

## Overview
The free5GC Helm chart provides a full 5G Core Standalone (SA) implementation:
<img width="2412" height="1518" alt="5G Core (1)" src="https://github.com/user-attachments/assets/4fb7c70b-9e27-4116-871d-945a719c3471" />


Including the following network functions (as subcharts):
 - [free5gc-amf](./charts/free5gc-amf) - Access and Mobility Management Function
 - [free5gc-ausf](./charts/free5gc-ausf) - Authentication Server Function
 - [free5gc-nrf](./charts/free5gc-nrf) - Network Repository Function
 - [free5gc-nssf](./charts/free5gc-nssf) Network Slice Selection Function
 - [free5gc-pcf](./charts/free5gc-pcf) - Policy Control Function
 - [free5gc-smf](./charts/free5gc-smf) - Session Management Function
 - [free5gc-udm](./charts/free5gc-udm) - Unified Data Management
 - [free5gc-udr](./charts/free5gc-udr) - Unified Data Repository
 - [free5gc-upf](./charts/free5gc-upf) - User Plane Function
 - [free5gc-webui](./charts/free5gc-webui) - used as GUI for subscriber provisioning and realtime status check
 - [mongodb](./charts/mongodb) - used as database backend for free5GC

---

## Customizations in this Chart
This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project. Each subchart has been customized for this deployment, with the details of those customizations documented in the respective subchart README files.  
In addition, a global `values.yaml` at the top level provides centralized configuration across the full free5GC deployment, including detailed networking configuration for cloud environment compatibility.

---

## Deployment

Deployed on demand via the Network Deployment Agent at `https://console.<domain>` or as part of an Argo Workflow (`5gcore-sub-prov-wf`, `5g-solution-wf`).

The agent applies the Argo CD Application wrapper at `5g/argocd-apps/free5gc-app/` with MCC and MNC parameters. See the [Network deployment guide](../../../docs/installation-instructions/01%20network-deployment.md).

---

## References
- [free5GC](https://free5gc.org/) – Open-source 5G Core implementation  
- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) – Helm charts for free5GC (reference project)

---

## License & Attribution
This chart is based on upstream projects licensed under Apache 2.0.  
Customizations and integrations are owned by © 5G Cloud Labs.

