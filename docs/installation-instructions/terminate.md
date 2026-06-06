# Terminate environment

1. Delete the ingress resource to terminate the ALB and related AWS resources:

```bash
kubectl -n istio-system delete ingress ingress
```

2. Destroy the remaining AWS infrastructure:

```bash
cd 5g-platform-aws/infrastructure
tofu destroy
```

Confirm with `yes` when prompted, or use `tofu destroy -auto-approve` in non-interactive environments.
