# Free5GC & UERANSIM Deployment via CLI Scripts

This directory contains automation scripts used to deploy the 5G Core (Free5GC), provision 5G Core subscribers and deploy the  UE/RAN simulation (UERANSIM) components.


## Scripts Overview

- **`free5gc-cli.sh`**  
  Prompts for MCC and MNC values, updates dependent scripts with these variables, and deploys the Free5GC Argo CD application, which installs the 5G Core Helm chart.

- **`subscriber-provisioner-cli.sh`**  
  Provisions the requested number of subscribers based on variables provided by the first script.

- **`ueransim-cli.sh`**  
  Deploys the UERANSIM Argo CD application using the previously defined MCC, MNC, and subscriber count to simulate gNB and UE connections.

---

## Deployment Workflow

<img width="860" height="508" alt="CLI Flow" src="https://github.com/user-attachments/assets/b0d33e97-1979-4221-b498-51959555ec55" />


© 2025 5g-cloud-labs (a project by CNAD LTD.)
