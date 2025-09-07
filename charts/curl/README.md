# Curl Helm Chart

## Purpose:

The `curl` pod is used by **5g-cloud-labs** for subscriber provisioning workflows.  

---

## Overview

This chart deploys a lightweight `curl` pod that supports automation scripts for subscriber provisioning operations within the 5G network deployment process.  

---

## Deployment

- Deployment is managed via Argo CD Application [`curl-app.yml`](../../argocd/required-apps/curl-app.yml).
- The pod uses the `curlimages/curl` container image.  

---

## References



---

## License & Attribution

This chart was created and is maintained by © 2025 5g-cloud-labs (a project by CNAD LTD.).
Licensed under the Apache License 2.0.

