# free5gc Helm chart

## Purpose
This Helm chart, adapted from the [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) project, deploys the complete free5GC 5G Core network on a public cloud environment, specifically optimized for Amazon EKS.  
It organizes all free5GC network functions as subcharts and manages their configuration for deployment.

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

1. **Console UI** – Provides a graphical interface for deploying and configuring free5GC.  
   After the infrastructure is created with OpenTofu, the UI can be accessed at: `https://console.$domain_name`.

2. **CLI script** – A Bash script that performs the deployment from the command line.  
   After cloning the repository to your local machine, the CLI script is available at: `aws-5gcloudlabs/scripts/cli/free5gc-cli.sh`

---

## References
- [free5GC](https://free5gc.org/) – Open-source 5G Core implementation  
- [towards5gs-helm](https://github.com/Orange-OpenSource/towards5gs-helm) – Helm charts for free5GC (reference project)

---

## License & Attribution
This chart is based on upstream projects licensed under Apache 2.0.  
Customizations and integrations are owned by © 2025 5g-cloud-labs (a project by CNAD LTD.).

