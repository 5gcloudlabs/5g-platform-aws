# Terminate environment

Tear down the laboratory when it is not in use to stop ongoing AWS charges (approximately USD 3.50–4.00/hour in usage, ~USD 4.50/hour including applicable taxes while the environment is running).

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
