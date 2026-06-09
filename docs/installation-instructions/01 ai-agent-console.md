
## Telco Deployment Assistant — deploy and validate the telecom environment

Part of **5G Platform AWS**. Phase 2 of the platform workflow.

After OpenTofu provisioning and cluster bootstrap are complete, all telecom deployments are driven through the **Telco Deployment Assistant** at `https://console.<your-domain>`. The assistant is implemented as the `ai-agent` service (Amazon Bedrock — Anthropic Claude Haiku 4.5 — with a FastAPI backend). There is no separate CLI or legacy click-through UI.

---

### 1. Open the console

```text
https://console.<your-domain>
```

The assistant is a chat interface backed by Amazon Bedrock (Anthropic Claude Haiku 4.5). You describe what you want in natural language; it collects MCC, MNC, and (when needed) subscriber count, then triggers the appropriate deployment on the cluster.

---

### 2. How the Telco Deployment Assistant works

| Layer | Role |
|-------|------|
| Bedrock / Claude Haiku 4.5 (intent) | Parses your message and selects exactly one deployment option. |
| Parameter extraction | Collects MCC, MNC, and count only when you explicitly provide them. |
| Manifest fetch | Reads workflow and ArgoCD app YAML from this repository (`GITHUB_RAW_BASE` in the ai-agent Helm values). |
| Execution | Single-step apps are applied with `kubectl`; multi-step flows are submitted as Argo Workflows. |

#### Deployment options

**Single-step** (one operation per request):

| Option | What it deploys | Required parameters |
|--------|-----------------|---------------------|
| 5G core only | free5GC network functions | MCC, MNC |
| Subscriber provisioning only | `sub-prov` Job | MCC, MNC, count |
| RAN/UE simulation only | UERANSIM | MCC, MNC, count |

**Combined workflows** (multi-step, one Argo Workflow):

| Workflow | Steps | Required parameters |
|----------|-------|---------------------|
| Core + subscribers | free5GC → sub-prov | MCC, MNC, count |
| Subscribers + simulation | sub-prov → UERANSIM *(core must already be running)* | MCC, MNC, count |
| Full solution | free5GC → sub-prov → UERANSIM | MCC, MNC, count |

#### Example prompts

```text
Deploy the 5G core with MCC 602 and MNC 02
```

```text
Deploy the full 5G solution with MCC 602, MNC 02, and 10 subscribers
```

```text
Deploy 5G core and create 10 subscribers
```
*(The agent asks for MCC/MNC if omitted, then runs the core + sub-prov workflow.)*

```text
Provision 5 subscribers with MCC 602 MNC 02
```
*(Assumes the core is already deployed.)*

If parameters are missing, the agent asks follow-up questions in plain language before triggering anything.

---

### 3. Monitor deployment in the console

While a deployment runs, the assistant reports progress in friendly terms (network function status, next suggested step, etc.).

You can also check status directly:

```bash
# 5G core pods
kubectl -n free5gc get pods

# UERANSIM pods
kubectl -n ueransim get pods

# Argo Workflows (multi-step deployments)
kubectl -n argo get workflows

# Argo CD applications created by workflows
kubectl -n argocd get applications | grep -E 'free5gc|sub-prov|ueransim'
```

---

### 4. Validate the 5G core

After the core is deployed (single-step or as part of a workflow):

#### 4.a) Pod status

```bash
kubectl -n free5gc get pods
```

All free5GC network function pods and `mongodb-0` should be `Running` (typically `2/2` with Istio sidecars).

#### 4.b) SBI registration (NRF)

```bash
kubectl -n free5gc exec -it mongodb-0 -- mongo free5gc \
  --eval 'db.NfProfile.find({ nfType: "UDM" }).pretty()'
```

Confirm `"nfStatus": "REGISTERED"` and the expected PLMN in `plmnList`.

#### 4.c) Multus interfaces (N2 / N4 / N3 / N6)

```bash
# AMF — N2
kubectl -n free5gc exec -it $(kubectl -n free5gc get pod -l nf=amf -o name) -- ip address show

# SMF — N4
kubectl -n free5gc exec -it $(kubectl -n free5gc get pod -l nf=smf -o name) -- ip address show

# UPF — N3, N4, N6
kubectl -n free5gc exec -it $(kubectl -n free5gc get pod -l nf=upf -o name) -- ip address show
```

Expect secondary interfaces in the `100.64.x.x/28` ranges (e.g. AMF `100.64.1.10`, SMF `100.64.4.10`, UPF `100.64.3.10` / `100.64.5.10` / `100.64.6.10`).

#### 4.d) SMF ↔ UPF PFCP (N4)

```bash
kubectl -n free5gc logs $(kubectl -n free5gc get pod -l nf=smf -o name) | grep PFCP
```

Look for `PFCP Association Setup Accepted Response from UPF`.

---

### 5. Validate subscriber provisioning

After sub-prov completes:

```bash
kubectl -n free5gc logs job/sub-prov-job
```

Verify MongoDB collections were created:

```bash
kubectl -n free5gc exec -it mongodb-0 -- mongo free5gc --eval 'db.getCollectionNames()'
```

Expected collections include:

- `subscriptionData.authenticationData.authenticationSubscription`
- `subscriptionData.provisionedData.amData`
- `subscriptionData.provisionedData.smData`
- `policyData.ues.amData`
- `policyData.ues.smData`

IMSI numbering starts at `{MCC}{MNC}0000000001`.

---

### 6. Validate UERANSIM

```bash
kubectl -n ueransim get pods
```

#### 6.a) gNB ↔ AMF (N2 / NGAP)

```bash
kubectl -n ueransim logs $(kubectl -n ueransim get pod -l component=gnb -o name) | grep 'sctp\|NG'
```

Expect SCTP established and `NG Setup procedure is successful`.

#### 6.b) UE registration and PDU session

```bash
kubectl -n ueransim logs $(kubectl -n ueransim get pod -l component=ue -o name)
```

Look for `Initial Registration is successful` and `PDU Session establishment is successful`.

#### 6.c) UE IP allocation

```bash
kubectl -n ueransim exec -it $(kubectl -n ueransim get pod -l component=ue -o name) -- ip a
```

Expect `uesimtun*` interfaces with addresses from `10.1.0.0/16`.

---

### 7. End-to-end connectivity test

Ping from a UE tunnel interface through the user plane to the internet:

```bash
kubectl -n ueransim exec -it $(kubectl -n ueransim get pod -l component=ue -o name) \
  -- ping -c 4 -I uesimtun0 google.com
```

The assistant can also trigger a latency test via its backend (`/test/latency`).

Successful replies with 0% packet loss confirm UE → gNB → UPF → external network connectivity.

---

### 8. Observability

| URL | Purpose |
|-----|---------|
| `https://grafana.<domain>` | UE registration, PDU session, and service mesh dashboards |
| `https://prometheus.<domain>` | Metrics |
| `https://free5gc.<domain>` | free5GC WebUI (subscriber management) |
| `https://argocd.<domain>` | GitOps application status |

---

### Congratulations

You have deployed and validated a telecom environment on AWS EKS using the Telco Deployment Assistant.
