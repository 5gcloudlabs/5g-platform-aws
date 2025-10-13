graph TD

A[OpenTofu IaC] --> B[AWS Resources]
B --> C[EKS Cluster]
C --> D[Kubernetes Add-ons]
D --> E[Argo CD (GitOps)]
E --> F[5G Workloads (Free5GC & UERANSIM)]

B -->|Networking, Storage, IAM| C
C -->|Helm Charts| D
D -->|Manages Deployments| F
