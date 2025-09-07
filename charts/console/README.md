## Console UI Helm Chart

### Purpose

This Helm chart deploys the **5G Cloud Labs Console UI**, a web-based interface for the [aws-5gcloudlabs](https://github.com/5g-cloud-labs/aws-5gcloudlabs) project.  

---

### Overview

The Console UI provides an interactive **web interface** to simplify the end-to-end deployment and testing of a **5G Core Network (free5GC)** and **RAN/UE simulation (UERANSIM)** on **Amazon EKS**. 

It enables users to:
- Deploy the 5G Core Network ([free5GC](https://github.com/free5gc/free5gc) network functions such as AMF, AUSF, NRF, NSSF, PCF, SMF, UDM, UDR, UPF).
- Provision Subscribers
- Simulate gNBs and UEs using [UERANSIM](https://github.com/aligungr/UERANSIM).  
- Monitor Pod Readiness & Logs for both network functions and simulations.
- Test the 5G network Latency & Bandwidth.


---

### Deployment

- This chart is deployed and managed via Argo CD.
- The corresponding Argo CD Application manifest is defined in
  [`curl-app.yml`](../../argocd/required-apps/console-app.yml).
- The application manifest is included in the **required apps** set and is deployed automatically by Argo CD during cluster bootstrap.
- The Console UI is packaged as a Docker container



### Notes

This chart is maintained locally in the `aws-5gcloudlabs` repository, by 5g-cloud-labs.
