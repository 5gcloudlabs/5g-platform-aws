# Free5GC & UERANSIM Deployment via CLI Scripts

This directory contains automation scripts that streamline the full deployment of the 5G Core Network, subscriber provisioning, and RAN/UE simulation on Amazon EKS.  
Each script leverages Argo CD `Applications` and Helm charts stored in this repository to ensure reproducible, declarative deployments.

---

## Script Overview

| Script | Description |
|--------|-------------|
| **free5gc-cli.sh** | Prompts the user to input **MCC** (Mobile Country Code) and **MNC** (Mobile Network Code). These values are propagated to dependent scripts and configuration files. The script then deploys the **free5GC Argo CD Application**, which installs the 5G Core Network via the corresponding Helm chart. |
| **subscriber-provisioner-cli.sh** | Provisions the requested number of 5G subscribers using the previously set MCC and MNC values. This script updates environment variables accordingly and triggers subscriber provisioning within the deployed 5G Core. |
| **ueransim-cli.sh** | Deploys the **UERANSIM** Argo CD Application, which launches simulated gNB and UE instances. The script reuses the MCC, MNC, and subscriber count from the previous steps to ensure a consistent test environment. |



© 2025 5g-cloud-labs (a project by CNAD LTD.)
