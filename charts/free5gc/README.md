# free5gc Helm chart

## Purpose
This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the complete free5GC 5G Core network on a public cloud environment, specifically optimized for Amazon EKS.  
It provides a centralized umbrella chart that manages all free5GC network functions as subcharts, enabling streamlined configuration and deployment.


---

## Overview
The free5GC Helm chart provides a full 5G Core Standalone (SA) implementation, including the following network functions (as subcharts):
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
Deployment of the free5GC chart can be triggered in two ways:

1. **Console UI** – Provides a graphical interface for inputting parameters such as `MCC` and `MNC`.  
   These values are stored in Kubernetes ConfigMaps, substituted into the Argo CD Application manifest, and applied to deploy the chart with the appropriate overrides.  

2. **CLI** – A Bash script accepts the required variables and uses `envsubst` to generate a customized Argo CD Application manifest.  
   Applying this manifest triggers Argo CD to deploy the free5GC chart with the specified configuration.  

In both cases, Argo CD manages reconciliation against the Helm charts in this repository, ensuring consistent and repeatable deployments.

## References
- [free5GC](https://free5gc.org/) – Open-source 5G Core implementation  
- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) – Helm charts for free5GC (reference project)

## License & Attribution
This chart is based on upstream projects licensed under Apache 2.0.  
Customizations and integrations are owned by © 2025 5g-cloud-labs (a project by CNAD LTD.).

