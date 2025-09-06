# MongoDB Helm Chart

## Purpose

This Helm chart, derived from the upstream [Bitnami MongoDB chart](https://github.com/bitnami/charts/tree/main/bitnami/mongodb), deploys the [free5GC](https://github.com/free5gc/free5gc) MongoDB on a public cloud environment, specifically optimized for Amazon EKS.

## Overview
Within this solution, MongoDB serves as the **database backend** for free5GC, storing subscriber profiles, network functions profiles & session data.

---

## Customizations in this Chart

This chart has been adapted to enable deployment on Amazon EKS.
Persistent storage for MongoDB is provided by Amazon EFS through the EFS CSI Driver. A dedicated StorageClass (efs-sc) references the pre-created EFS file system, allowing MongoDB to leverage dynamically provisioned PersistentVolumes (PVs) for durable and scalable file system storage.
This design ensures that MongoDB benefits from EFS’s scalability and availability while keeping storage management **fully automated and Kubernetes-native**.

Customizations can be found in:  
- [MongoDB values.yaml](./values.yaml)  
- [global values.yaml](../../values.yaml)  


---

## Deployment

Deployment is managed via Argo CD Application [`free5gc-app.base`](../../../../argocd/free5gc-app/free5gc-app.base).

---


## References

- [Bitnami MongoDB Chart](https://github.com/bitnami/charts/tree/main/bitnami/mongodb)  
- [Amazon EFS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html)  
- [Kubernetes StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/)  

---

## License & Attribution

This chart is based on the Bitnami MongoDB chart (Apache 2.0).  
Modifications and integrations are owned by © 2025 5g-cloud-labs (a project by CNAD LTD.).
