# Console UI Helm Chart

## Purpose

This Helm chart deploys the 5G Cloud Labs Console UI on Amazon EKS. 
The Console UI serves as the user-facing interface for interacting with the 5G Cloud Labs environment.

---

## Overview

The Console UI provides an interactive web interface to simplify the end-to-end deployment and testing of a 5G Core Network (free5GC) and RAN/UE simulation (UERANSIM) on Amazon EKS. 

It enables users to:
- Deploy the 5G Core Network ([free5GC](https://github.com/free5gc/free5gc) network functions such as AMF, AUSF, NRF, NSSF, PCF, SMF, UDM, UDR, UPF).
- Provision Subscribers
- Deploy UE & gNB and simulators using [UERANSIM](https://github.com/aligungr/UERANSIM).  
- Monitor Pod Readiness & Logs for both network functions and simulations.
- Test the 5G network Latency & Bandwidth.


---

## Deployment

- This chart is deployed and managed via Argo CD.
- The corresponding Argo CD Application manifest is defined in
  [`console-app.yml`](../../argocd/required-apps/console-app.yml).
- The application manifest is included in the "required-apps" set and is deployed automatically by Argo CD post EKS cluster creation.
- The pod runs the container image `ghcr.io/5g-cloud-labs/console-ui:<tag>`.
- The source code repository is available at [https://github.com/5g-cloud-labs/console-ui](https://github.com/5g-cloud-labs/console-ui), using the "aws" branch for builds.

---

## References

[https://github.com/curl/curl-container](https://flask.palletsprojects.com/en/stable/)

---

## License & Attribution

This chart was created and is maintained by © 2025 5g-cloud-labs (a project by CNAD LTD.).
<br>Licensed under the Apache License 2.0.

