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


<img width="857" height="508" alt="free5gc-cli-flow" src="https://github.com/user-attachments/assets/837cb596-174a-4bdc-9a6e-8b788e259629" />

      
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


- ### `ueransim-cli.sh`

<img width="824" height="508" alt="ueransim-cli-flow" src="https://github.com/user-attachments/assets/517ac857-1f7e-43bb-8fb7-702f5d451336" />


When executed, the script performs the following operations:

- **Applies the UERANSIM Argo CD Application manifest**  
   The script runs `kubectl apply` to deploy the UERANSIM Argo CD `Application` resource located at  
   `../../argocd-apps/ueransim-app/ueransim-app.yml`.

- **Triggers the Argo CD deployment process**  
   Once applied, Argo CD detects the new `ueransim-app` definition and begins deploying the corresponding Helm chart (`charts/ueransim`) into the cluster.

- **Leverages previously configured variables**  
   The UERANSIM deployment automatically uses MCC, MNC, and subscriber count values set earlier by the  
   `free5gc-cli.sh` and `subscriber-provisioner-cli.sh` scripts to ensure consistent configuration between the 5G Core and UE/RAN simulation.

- **Launches UE and gNB simulations**  
   After synchronization, the UERANSIM pods (UE and gNB) start within the designated namespace, connecting to the deployed free5GC core to complete end-to-end 5G registration and session setup testing.


Before running these scripts, ensure that the repository is cloned locally and the **infrastructure has been successfully deployed and validated** — including the EKS cluster, Argo CD, and supporting add-ons.

© 2025 5g-cloud-labs (a project by CNAD LTD.)
