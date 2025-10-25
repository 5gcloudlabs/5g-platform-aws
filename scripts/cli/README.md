# 5G Deployment via CLI Scripts

This directory contains automation scripts that streamline the full deployment of the 5G Core Network, subscriber provisioning, and RAN/UE simulation on Amazon EKS.  
Each script leverages Argo CD `Applications` and Helm charts stored in this repository to ensure reproducible, declarative deployments.

---

## Script Overview

| Script | Description |
|--------|-------------|
| **free5gc-cli.sh** | Prompts the user to input **MCC** (Mobile Country Code) and **MNC** (Mobile Network Code). These values are propagated to dependent scripts and configuration files. The script then deploys the **free5GC Argo CD Application**, which installs the 5G Core Network via the corresponding Helm chart. |
| **subscriber-provisioner-cli.sh** | Provisions the requested number of 5G subscribers using the previously set MCC and MNC values. This script updates environment variables accordingly and triggers subscriber provisioning within the deployed 5G Core. |
| **ueransim-cli.sh** | Deploys the **UERANSIM** Argo CD Application, which launches simulated gNB and UE instances. The script reuses the MCC, MNC, and subscriber count from the previous steps to ensure a consistent test environment. |

---

## Deployment Flow

1. **Run `free5gc-cli.sh`**  
   - Set MCC and MNC.  
   - Deploy the 5G Core Network (`free5gc`).

2. **Run `subscriber-provisioner-cli.sh`**  
   - Provision the desired number of subscribers.  

3. **Run `ueransim-cli.sh`**  
   - Deploy RAN and UE simulations using the existing 5G Core configuration.

Each step builds upon the previous one, enabling a fully functional 5G testbed from core to user equipment simulation.

---

## Notes

- All deployments are short-lived and intended for test or trial environments.  
- The scripts interact directly with **Argo CD** to trigger application deployments and with **Kubernetes** resources via `kubectl`.  
- Environment variables such as `MCC`, `MNC`, and `COUNT` are automatically passed between scripts for seamless operation.

---

© 2025 5g-cloud-labs (a project by CNAD LTD.)
