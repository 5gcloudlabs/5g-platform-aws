# 5G Cloud Labs

**An open-source R&D platform for developing, integrating, and evaluating network automation and AI use cases using reproducible cloud-based 5G network environments.**

---

## Overview

5G Cloud Labs is organized around two complementary repository types:

- **Platform Environments** provide reproducible cloud-based 5G network environments where use cases can be integrated and evaluated.
- **Use Case Repositories** contain independent automation and AI capabilities that can be developed, tested, and evolved separately before integration.

This separation allows platform environments and use cases to evolve independently while providing a consistent model for end-to-end evaluation.

---

## Project Model

```text
                          5G Cloud Labs
                                 │
          ┌──────────────────────┴──────────────────────┐
          │                                             │
          ▼                                             ▼
  Platform Environments                    Use Case Repositories
          │                                             │
          └──────────────────────┬──────────────────────┘
                                 │
                                 ▼
                     End-to-End Evaluation
```

Platform Environments provide reproducible integration laboratories.

Use Case Repositories focus on solving individual automation or AI problems independently before they are integrated into one or more Platform Environments.

---

## Repository Types

### Platform Environments

Platform Environments provide the infrastructure, Kubernetes platform, networking, observability, and deployable network components required for end-to-end evaluation.

Current and planned Platform Environments include:

| Repository | Cloud | Description |
|------------|-------|-------------|
| **5g-platform-aws** | AWS | AWS Platform Environment |
| **5g-platform-gcp** *(planned)* | GCP | GCP Platform Environment |

Each Platform Environment follows the same contributor model while providing cloud-specific implementation details.

---

### Use Case Repositories

Use Case Repositories implement individual automation or AI capabilities independently of any specific Platform Environment.

Current repository:

| Repository | Description |
|------------|-------------|
| **network-deployment-agent** | AI-assisted network deployment and provisioning through a natural language interface |

Additional repositories can be created whenever a new automation or AI capability is developed.

---

## Contributor Workflow

Most contributions do **not** require a deployed Platform Environment.

Development typically follows this workflow:

```text
Develop Locally
       │
       ▼
Use Case Repository
       │
       ▼
Platform Environment
       │
       ▼
End-to-End Evaluation
```

Developers can build and validate new capabilities locally before integrating them into a Platform Environment for evaluation against a reproducible 5G network environment.

---

## Example Use Cases

5G Cloud Labs is intentionally open-ended.

Examples of use cases that fit naturally within the project include:

- AI-assisted network deployment
- Intent-based network operations
- Network provisioning automation
- Day-2 operational automation
- AI-assisted troubleshooting
- Configuration management
- Network validation
- Observability and analytics
- Operational copilots
- Policy-driven orchestration

The Network Deployment Agent is the first integrated use case, demonstrating how independent capabilities can be integrated into a Platform Environment for end-to-end evaluation.

---

## Project Vision

5G Cloud Labs is designed as a growing collection of Platform Environments and Use Case Repositories.

Platform Environments provide consistent integration laboratories where ideas can be evaluated against comparable 5G network scenarios regardless of the underlying cloud provider.

Use Case Repositories remain independent projects, allowing them to evolve at their own pace while being integrated into one or more Platform Environments.

As the project evolves, additional cloud providers, operational tooling, automation frameworks, and AI capabilities may be added while preserving the same development model.

---

## Getting Started

| Goal | Start Here |
|------|------------|
| Learn about the project | This page |
| Deploy a Platform Environment | **5g-platform-aws** |
| Develop a new capability | Create or contribute to a Use Case Repository |
| Integrate a capability | Open a pull request against the appropriate Platform Environment |

---

## Contributing

Contributions are welcome across both Platform Environments and Use Case Repositories.

Choose the repository that best matches the change you want to make.

Most development can begin locally without deploying a Platform Environment.

Platform Environments are intended for integration and end-to-end evaluation once a capability is ready.

If you're unsure where a contribution belongs, feel free to open an issue for discussion.

---

## Links

🌐 **Website**

https://5gcloudlabs.ai

📧 **Contact**

info@5gcloudlabs.ai
