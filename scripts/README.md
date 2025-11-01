# Deployment Scripts

This directory contains automation scripts used to deploy and manage components of the **AWS 5G Cloud Labs** environment.

## Structure

| Folder | Description |
|---------|-------------|
| **cli/** | Contains CLI-based scripts for deploying the Free5GC 5G Core, provisioning subscribers, and deploying UERANSIM manually from a local environment. |
| **ui/** | Contains Console-UI automation scripts executed inside the Executor Pod, enabling web-based deployments triggered from the Console UI interface. |

## Notes

Both script sets serve the same purpose — deploying and managing the 5G Core and simulated RAN/UE components — but differ in how they are executed:  
- **CLI scripts** are intended for local or manual operations.  
- **UI scripts** are integrated with the Console UI for automated deployments within the Kubernetes cluster.
