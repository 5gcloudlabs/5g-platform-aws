# Deployment via Console-UI Scripts

This directory contains automation scripts used by the **Console UI** to deploy the **Free5GC 5G Core**, provision subscribers, and deploy the **UERANSIM** UE/RAN simulation components automatically within the Kubernetes cluster.

These scripts are not executed directly by users — they are triggered by the **Console UI** inside the **Executor Pod**, which handles configuration and deployment workflows based on user input provided through the web interface.

---

## How It Works

- The **Executor Pod** includes an **initContainer** that clones the Git repository, ensuring the latest deployment scripts are always available.
- Configuration values (e.g., **MCC**, **MNC**, and subscriber **count**) are stored in mounted **ConfigMaps**, which are dynamically updated by the Console UI.
- When triggered, each script loads these environment variables from the mounted files, substitutes them into the corresponding Argo CD manifests or helper scripts, and applies them via `kubectl`.

---

## Scripts Overview

- **`free5gc-ui.sh`**  
  Deploys the Free5GC 5G Core through Argo CD using MCC and MNC values provided by the user in the Console UI.

- **`subscriber-provisioner-ui.sh`**  
  Provisions the requested number of subscribers in the Free5GC core automatically, using the values from the ConfigMap.

- **`ueransim-ui.sh`**  
  Deploys the UERANSIM Argo CD application to simulate gNB and UE connections using the previously configured MCC, MNC, and subscriber count.

---

## GUI Scripts Workflow

### `free5gc-ui.sh`

<img width="1157" height="940" alt="free5gc-gui-flow" src="https://github.com/user-attachments/assets/bb2840bd-2afd-491d-ab89-4db2be09f464" />

Under the Hood, this script performs the following operations:

1. **Loads environment variables from ConfigMap**  
   Reads the `vars.env` file mounted under `/free5gc-variables/` to retrieve user-provided MCC and MNC values.

2. **Generates Argo CD manifests and provisioning script**  
   Uses `envsubst` to inject variables into:
   - `/tmp/free5gc-app.yml` — the Free5GC Argo CD application manifest.  
   - `/tmp/subscriber-provisioner-ui.sh` — the subscriber provisioning script for the next phase.  
   - `/tmp/ueransim-app.tmp` — a temporary UERANSIM application manifest.

3. **Grants script execution permissions**  
   Makes `/tmp/subscriber-provisioner-ui.sh` executable for later use.

4. **Applies the Free5GC application manifest**  
   Executes `kubectl apply -f /tmp/free5gc-app.yml`, registering the Free5GC Application in Argo CD, which automatically deploys the 5G Core.

---

### `subscriber-provisioner-ui.sh`

Under the Hood, this script performs the following operations:

1. **Loads subscriber configuration from ConfigMap**  
   Reads `/subs-prov-variables/vars.env` to get MCC, MNC, and subscriber count.

2. **Generates IMSI range dynamically**  
   Calculates IMSI values based on MCC/MNC and subscriber count.

3. **Substitutes variables into the UERANSIM manifest**  
   Converts `/tmp/ueransim-app.tmp` into the final `/tmp/ueransim-app.yml` using `envsubst`.

4. **Provisions subscribers in Free5GC Core**  
   Iterates over each IMSI, executing a `curl` POST request to the Free5GC WebUI API (`webui-service.free5gc.svc.cluster.local:5000`) from inside the `curl-deployment` pod to register new subscribers.

5. **Logs output and prints results**  
   Captures all responses in `/tmp/output.log` and prints a summary of successfully provisioned IMSIs.

---

### `ueransim-ui.sh`

<img width="1157" height="940" alt="free5gc-gui-flow" src="https://github.com/user-attachments/assets/2683acfa-6d00-4ac6-9751-5782abcf146b" />

Under the Hood, this script performs the following operations:

1. **Applies the UERANSIM Argo CD Application manifest**  
   Runs `kubectl apply -f /tmp/ueransim-app.yml` to register the UERANSIM application in Argo CD.

2. **Triggers Argo CD synchronization**  
   Argo CD deploys the Helm chart (`charts/ueransim`) using the configured MCC, MNC, and subscriber count.

3. **Launches UE and gNB simulations**  
   Once deployed, the UERANSIM pods start and connect to the Free5GC core, completing end-to-end registration and session setup.

---


Before using the Console UI, ensure that:
- The **EKS cluster, Argo CD, and required add-ons** are running and validated.
- The **Executor Pod** and its **ConfigMaps** are properly deployed.
- The Git repository is accessible and synced to the latest version.

© 2025 5g-cloud-labs (a project by CNAD LTD.)

