# free5gc Helm chart

## Purpose
This Helm chart deploys the complete [free5GC](https://github.com/free5gc/free5gc) 5G Core network on Kubernetes.  
It is designed to run in a **public cloud environment** and has been optimized for **Amazon EKS** deployments.  
The chart follows an **Argo CD GitOps-style workflow** for lifecycle management.

---

## Overview
The free5GC Helm chart provides a full 5G Core Standalone (SA) implementation, including the following network functions (as subcharts):
 - [amf](./charts/free5gc-amf)
 - [free5gc-ausf](./charts/free5gc-ausf)
 - [free5gc-nrf](./charts/free5gc-nrf)
 - [free5gc-nssf](./charts/free5gc-nssf)
 - [free5gc-pcf](./charts/free5gc-pcf)
 - [free5gc-smf](./charts/free5gc-smf)
 - [free5gc-udm](./charts/free5gc-udm)
 - [free5gc-udr](./charts/free5gc-udr)
 - [free5gc-upf](./charts/free5gc-upf)
 - [free5gc-webui](./charts/free5gc-webui)





- **AMF** – Access and Mobility Management Function  
- **SMF** – Session Management Function  
- **UPF** – User Plane Function  
- **AUSF** – Authentication Server Function  
- **UDM** – Unified Data Management  
- **NRF** – NF Repository Function  
- **PCF** – Policy Control Function  
- **NSSF** – Network Slice Selection Function  
- **BSF** – Binding Support Function  
- **UDR** – Unified Data Repository  
- **MongoDB** – Database backend for free5GC  

Each subchart can be customized individually via `values.yaml`, and global configuration is centralized in `values.yaml` at the top level.

## Customizations in this Chart
This chart has been adapted from the upstream [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project.

Key customizations include:
- Adjusted networking configuration for compatibility with **Amazon EKS CNI**.  
- Integration with **Argo CD Applications** for GitOps-driven deployments.  
- Simplified configuration structure via a unified `values.yaml`.  
- Updates for compatibility with the latest `free5GC` release and dependencies.

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

