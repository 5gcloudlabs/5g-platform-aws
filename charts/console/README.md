# 5G Cloud Labs Console UI Helm Chart

This Helm chart deploys the **5G Cloud Labs Console UI**, a web-based interface for the [aws-5gcloudlabs](https://github.com/5g-cloud-labs/aws-5gcloudlabs) project.  



---

## 🌐 Overview

The Console UI provides an interactive **web interface** to simplify the end-to-end deployment and testing of a **5G Core Network (free5GC)** and **RAN/UE simulation (UERANSIM)** on **Amazon EKS**. It enables users to:

- **Deploy the 5G Core Network** (free5GC functions such as AMF, AUSF, NRF, NSSF, PCF, SMF, UDM, UDR, UPF).  
- **Provision Subscribers** with a guided web form.  
- **Simulate gNBs and UEs** using [UERANSIM](https://github.com/aligungr/UERANSIM).  
- **Monitor Pod Readiness & Logs** for both network functions and simulations.  

By abstracting away low-level Kubernetes operations, the Console UI delivers a seamless, browser-based experience for deploying and testing cloud-native 5G networks on AWS.

---

## Deployment

The Console UI is packaged as a **Docker container** and deployed via this Helm chart.  
It is typically managed as an **Argo CD Application**, enabling GitOps-based deployment and lifecycle management.
