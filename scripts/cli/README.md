# Free5GC & UERANSIM Deployment via CLI Scripts

This directory contains automation scripts used to deploy the 5G Core (Free5GC), provision 5G Core subscribers and deploy the  UE/RAN simulation (UERANSIM) components.


## Scripts Overview

- **`free5gc-cli.sh`**  
 This script automates the setup and deployment of the **free5GC 5G Core** via Argo CD.  

- **`subscriber-provisioner-cli.sh`**  
  Provisions the requested number of subscribers based on variables provided by the first script.

- **`ueransim-cli.sh`**  
  Deploys the UERANSIM Argo CD application using the previously defined MCC, MNC, and subscriber count to simulate gNB and UE connections.

---

## CLI Scripts Workflow

- ### `free5gc-cli.sh`

<img width="860" height="508" alt="CLI Flow" src="https://github.com/user-attachments/assets/b0d33e97-1979-4221-b498-51959555ec55" />

      
   Under the hood, **`free5gc-cli.sh` script** performs the following operations:

   - **Prompts for PLMN configuration**  
     Requests the **MCC** (Mobile Country Code) and **MNC** (Mobile Network Code) that define the 5G Core’s PLMN ID.

   - **Exports environment variables**  
     Sets the provided values as environment variables for use in template substitution.

   - **Generates deployment manifests and scripts**  
     Uses `envsubst` to inject the MCC/MNC values into:
       - `free5gc-app.yml` — the Argo CD `Application` manifest for deploying the free5GC Helm chart.  
       - `subscriber-provisioner-cli.sh` — the script used later for subscriber provisioning.  
       - `ueransim-app.tmp` — a temporary manifest for the upcoming UERANSIM deployment.

   - **Makes the provisioning script executable**  
     Grants execution permissions to `subscriber-provisioner-cli.sh`.

   - **Applies the Argo CD Application manifest**  
     Executes `kubectl apply -f free5gc-app.yml` to register the **free5GC Application** in Argo CD, which then automatically deploys the free5GC 5G Core components.

Before running this script, ensure that the repository is cloned locally and the **infrastructure has been successfully deployed and validated** — including the EKS cluster, Argo CD, and supporting add-ons.

© 2025 5g-cloud-labs (a project by CNAD LTD.)
