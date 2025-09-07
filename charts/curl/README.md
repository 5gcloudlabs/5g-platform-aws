# Curl Helm Chart

## Purpose:

The `curl` pod is used by **5g-cloud-labs** for subscriber provisioning workflows.  

---

## Overview

This chart deploys a lightweight `curl` pod that supports automation scripts for subscriber provisioning operations within the 5G network deployment process.  

---


## Deployment

- This chart is deployed and managed via Argo CD.
- The corresponding Argo CD Application manifest is defined in
  [`curl-app.yml`](../../argocd/required-apps/curl-app.yml).
- The application manifest is included in the **required apps** set and is deployed automatically by Argo CD during cluster bootstrap.
- The pod runs the container image `curlimages/curl:8.15.0`.


---

## References



---

## License & Attribution

This chart was created and is maintained by © 2025 5g-cloud-labs (a project by CNAD LTD.).
<br>Licensed under the Apache License 2.0.

