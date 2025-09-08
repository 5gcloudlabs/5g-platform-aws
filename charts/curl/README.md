# Curl Helm Chart

## Purpose

This Helm chart deploys a lightweight `curl` deployment on Amazon EKS. The curl pod supports subscriber provisioning workflow.

---

## Overview

The `curl` Deployment is used by automation scripts to provision subscribers into the 5G Core Network (free5GC).  
Provisioning scripts run `kubectl exec` inside the `curl` pod, which then issues REST API calls to the free5GC WebUI service containing the subscriber’s subscription information.

---

## Deployment

- This chart is deployed and managed via Argo CD.
- The corresponding Argo CD Application manifest is defined in
  [`curl-app.yml`](../../argocd/required-apps/curl-app.yml).
- The application manifest is included in the **required apps** set and is deployed automatically by Argo CD post EKS cluster creation.
- The pod runs the container image `curlimages/curl:8.15.0`.


---

## References

https://github.com/curl/curl-container

---

## License & Attribution

This chart was created and is maintained by © 2025 5g-cloud-labs (a project by CNAD LTD.).
<br>Licensed under the Apache License 2.0.

