# Curl Chart

This chart deploys a lightweight `curl` pod into the cluster.  

## Purpose

The `curl` pod is used by **5g-cloud-labs** for Subscriber provisioning workflows.


## Notes

- This chart is maintained locally as part of the 5G Cloud Labs automation.
- Deployment is managed automatically through Argo CD (`curl-app.yml`).
- The pod uses the [curlimages/curl](https://hub.docker.com/r/curlimages/curl) container image.
