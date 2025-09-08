# Curl Helm Chart

## Purpose

This Helm chart deploys a lightweight `curl` deployment on Amazon EKS.

---

## Overview

The `curl` pod enables subscriber provisioning workflow.

---

## Deployment

- This chart is deployed and managed via Argo CD.
- The corresponding Argo CD Application manifest is defined in
  [`curl-app.yml`](../../argocd/required-apps/curl-app.yml).
- The application manifest is included in the **required apps** set and is deployed automatically by Argo CD during cluster bootstrap.
- The pod runs the container image `curlimages/curl:8.15.0`.


---

## References

https://github.com/curl/curl-container

---

## License & Attribution

This chart was created and is maintained by © 2025 5g-cloud-labs (a project by CNAD LTD.).
<br>Licensed under the Apache License 2.0.

