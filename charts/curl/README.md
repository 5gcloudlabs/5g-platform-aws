# Curl Helm Chart

The `curl` pod is used by **5g-cloud-labs** for subscriber provisioning workflows.  

## Purpose

This chart deploys a lightweight `curl` pod that supports automation scripts for subscriber provisioning operations within the 5G network deployment process.  

## Deployment

- Deployment is managed via Argo CD Application [`curl-app.yml`](../../argocd/required-apps/curl-app.yml).
- The pod uses the `curlimages/curl` container image.  


## Notes

This chart is maintained locally in the `aws-5g-cloud-labs` repository.  


