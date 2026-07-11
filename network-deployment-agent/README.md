# Network Deployment Agent

**AI-assisted network deployment and provisioning through a natural language interface.**

Part of the **5G Cloud Labs** project — a **use case repository** for developing, testing, and evolving an independent automation and AI capability before integration into platform environments.

For the project-wide contributor model and repository roles, see the [5G Cloud Labs organization profile](https://github.com/5gcloudlabs).

---

## Overview

The Network Deployment Agent translates operator intent into deployment and provisioning actions on a running 5G platform environment.

Users describe what they want in natural language — for example, deploying the 5G Core, provisioning subscribers, or running a full end-to-end scenario. The agent interprets that intent, collects required parameters when needed, and triggers the appropriate deployment on the cluster.

It is the primary **operate** interface for platform environments such as [`5g-platform-aws`](https://github.com/5gcloudlabs/5g-platform-aws), where network components are deployed on demand rather than during initial platform installation.

---

## Why This Use Case Exists

Deploying and provisioning a 5G network environment involves multiple steps, parameters, and orchestration paths. Manual execution through CLI commands and fixed scripts increases friction and makes experimentation harder.

This use case explores whether a natural language interface — backed by a large language model (LLM) — can simplify those workflows while remaining connected to reproducible, GitOps-driven automation on the platform.

The agent is developed here as an independent capability. It is integrated into platform environments when ready for end-to-end evaluation against realistic network components.

---

## What It Does

The Network Deployment Agent currently supports:

- **Guided deployment** — natural-language chat at `https://console.<your-domain>`
- **Parameter collection** — MCC, MNC, and subscriber count when required
- **Single-step deployments** — individual network components via Argo CD Applications
- **Multi-step workflows** — coordinated deployments via Argo Workflows
- **Operational feedback** — progress and status in plain language during deployment
- **Connectivity validation** — optional latency and reachability checks through the user plane

### Deployment options

**Single-step** (one operation per request):

| Option | Deploys | Required parameters |
|--------|---------|---------------------|
| 5G Core only | Free5GC network functions | MCC, MNC |
| Subscriber provisioning only | `sub-prov` Job | MCC, MNC, count |
| RAN/UE simulation only | UERANSIM | MCC, MNC, count |

**Combined workflows** (multi-step, one Argo Workflow):

| Workflow | Steps | Required parameters |
|----------|-------|---------------------|
| Core + subscribers | Free5GC → sub-prov | MCC, MNC, count |
| Subscribers + simulation | sub-prov → UERANSIM *(core must already be running)* | MCC, MNC, count |
| Full solution | Free5GC → sub-prov → UERANSIM | MCC, MNC, count |

### Example prompts

```text
Deploy the 5G core with MCC 602 and MNC 02
```

```text
Deploy the full 5G solution with MCC 602, MNC 02, and 10 subscribers
```

If parameters are missing, the agent asks follow-up questions before triggering any action.

---

## Architecture

```text
          User
            │
            ▼
   Web interface (Chainlit)
            │
            ▼
   Agent backend (FastAPI)
            │
     ┌──────┴──────┐
     ▼             ▼
 Amazon Bedrock   Platform automation
 (Claude Haiku    (Argo CD Applications,
  4.5 — intent)    Argo Workflows, kubectl)
            │
            ▼
   Network components on EKS
   (Free5GC · sub-prov · UERANSIM)
```

| Component | Role |
|-----------|------|
| **Frontend** | Chat interface for operator interaction |
| **Backend** | Intent handling, parameter extraction, orchestration |
| **Amazon Bedrock** | LLM inference for intent selection (Anthropic Claude Haiku 4.5) |
| **Manifest fetch** | Reads deployment and workflow YAML from the platform repository |
| **Execution** | Applies Argo CD Applications or submits Argo Workflows on the cluster |

On platform environments, the agent runs as the `network-deployment-agent` Kubernetes service (`network-deployment-agent-frontend`, `network-deployment-agent-backend` in the `network-deployment-agent` namespace).

---

## How It Works

1. The user sends a message through the web interface.
2. Bedrock parses intent and selects exactly one deployment option.
3. The backend collects MCC, MNC, and count only when explicitly provided or required.
4. Deployment manifests are fetched from the platform repository (`GITHUB_RAW_BASE`).
5. Single-step operations are applied with `kubectl`; multi-step flows are submitted as Argo Workflows.
6. The agent reports progress and suggested next steps while work runs on the cluster.

Platform administration, troubleshooting, and advanced validation can still be performed through standard Kubernetes and cloud tooling when required.

---

## Repository Layout

```text
.
├── frontend/          Chainlit web interface
├── backend/           FastAPI agent service
├── prompts/           LLM intent and orchestration logic
├── tests/             Unit and integration tests
└── docs/              Use case documentation
```

Exact layout may evolve as the use case matures. Deployment packaging for platform integration lives in [`5g-platform-aws`](https://github.com/5gcloudlabs/5g-platform-aws) under `cluster-bootstrap/helm-charts/network-deployment-agent/`.

---

## Development

Contributors do **not** need a deployed platform environment for all work on this use case.

| Stage | Where | What happens |
|-------|-------|--------------|
| **Develop** | This repository or your workstation | Build and validate agent logic, prompts, and API behaviour |
| **Integrate** | Platform environment (e.g. `5g-platform-aws`) | Deploy via the platform Helm chart and run end-to-end evaluation |
| **Operate** | Deployed platform | Validate against live network components and automation workflows |

Typical local work includes backend development, prompt iteration, unit tests, and API testing. End-to-end evaluation on AWS is used when a change is ready to be tested against a full 5G network environment.

---

## Platform Integration

The agent is integrated into platform environments during cluster bootstrap.

| Platform | Integration path |
|----------|------------------|
| [`5g-platform-aws`](https://github.com/5gcloudlabs/5g-platform-aws) | Helm chart at `cluster-bootstrap/helm-charts/network-deployment-agent/`, synced by Argo CD as application `network-deployment-agent` |

After platform provisioning and bootstrap:

1. Open `https://console.<your-domain>`.
2. Deploy and provision network components through the agent.
3. Validate behaviour on the running platform.

Operational guide on AWS: [Network deployment](https://github.com/5gcloudlabs/5g-platform-aws/blob/5g-platform-aws/docs/installation-instructions/01%20network-deployment.md) in `5g-platform-aws`.

---

## Configuration

Key runtime settings (provided via the platform Helm chart or environment):

| Variable | Purpose |
|----------|---------|
| `DOMAIN_NAME` | Public domain for console and platform URLs |
| `BEDROCK_REGION` | AWS region for Bedrock API calls |
| `BEDROCK_MODEL_ID` | Bedrock model or inference profile (Claude Haiku 4.5) |
| `GITHUB_RAW_BASE` | Base URL for fetching platform deployment manifests |
| `ARGO_WF_BASE_PATH` | Path to Argo Workflow templates in the platform repo |
| `ARGOCD_APPS_BASE_PATH` | Path to Argo CD Application wrappers in the platform repo |
| `CORE_NAMESPACE` | Namespace for Free5GC (default `free5gc`) |
| `UERANSIM_NAMESPACE` | Namespace for UERANSIM (default `ueransim`) |

Bedrock access requires appropriate IAM permissions on the platform (IRSA role attached to the `network-deployment-agent` service account).

---

## Contributing

Contributions are welcome in this repository.

- **Agent logic, prompts, frontend, backend** — develop and test here.
- **Platform wiring, Helm values, manifest paths** — integrate and validate in the appropriate [platform environment](https://github.com/5gcloudlabs/5g-platform-aws).

Open an issue or pull request to discuss changes, integration points, or new deployment capabilities.

---

## Related Repositories

| Repository | Role |
|------------|------|
| [`5g-platform-aws`](https://github.com/5gcloudlabs/5g-platform-aws) | AWS platform environment — integrates and evaluates this use case |
| `5g-platform-gcp` | Future platform environment *(planned)* |

---

## License

Apache License 2.0

---

## Maintainer

**5G Cloud Labs**

🌐 Website: https://5gcloudlabs.ai

📧 Contact: info@5gcloudlabs.ai
