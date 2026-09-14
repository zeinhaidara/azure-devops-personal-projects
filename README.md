# Cloud & DevOps

Hands-on Azure labs covering infrastructure, security, containers, Kubernetes, and CI/CD.

## Labs

### ARM JSON — Legacy Application
- Modular templates for networking, Linux VM, SQL Database, and Key Vault
- Secure SQL password parameter and template orchestration

### Kubernetes — Demo Application
- ASP.NET 8 app with `/` and `/health` endpoints
- Multi-stage Docker image and ACR workflow
- Shared AKS cluster with a unique namespace, names, and port
- Deployment with 2 replicas and LoadBalancer Service
- CI builds immutable `$(Build.BuildId)` images; CD deploys them

## Rules
- Secrets stay in Key Vault or Azure DevOps secret variables.
- Terraform state is remote in Azure Storage.
- Infrastructure changes are version-controlled and pipeline-driven.
- Shared AKS resources must never be modified or overwritten.
