# 🚀 DevOps Lab

A production-grade DevOps laboratory using a NestJS + PostgreSQL API as the base application to demonstrate modern infrastructure practices with Kubernetes, Terraform, Helm, and CI/CD.

## 🛠️ Stack

**Application:** NestJS, Prisma, PostgreSQL, JWT

**Infrastructure:**
- **Containerization:** Docker & Docker Compose
- **Orchestration:** Kubernetes — Kind (local) / Amazon EKS (cloud)
- **IaC:** Terraform — VPC, EKS, ECR, AWS Load Balancer Controller
- **Automation:** Makefile
- **Package Manager:** Helm — custom charts for application deployment
- **CI/CD:** GitHub Actions — automated build and push to Amazon ECR
- **Registry:** Amazon ECR
- **Secrets Management:** Sealed Secrets
- **DNS:** External DNS integrated with Route 53
- **Configuration Management:** Ansible with Vagrant for local testing

## 🏁 Running Locally (Kind)

### Prerequisites
- Docker
- Kind
- kubectl
- Helm

### Setup

```bash
make setup-dev   # creates Kind cluster, installs ingress-nginx and postgres via Helm
make deploy-dev  # builds image, loads into Kind and applies manifests
```

### Teardown

```bash
make teardown-dev
```

## ☁️ AWS Infrastructure (Terraform)

> Infrastructure provisioned using the Terraform modules from [terraform-aws](https://github.com/gaabrieltorres7/terraform-aws).

### Prerequisites
- AWS CLI configured
- Terraform

### Provisioning

```bash
cd terraform
terraform init
terraform apply
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

### Infrastructure Overview

- **VPC** with public and private subnets across 2 availability zones
- **Internet Gateway** for public subnets
- **NAT Gateways** (one per AZ) for private subnets
- **Amazon EKS** cluster with managed node group
- **AWS Load Balancer Controller** installed via Helm
- **Amazon ECR** repository for Docker images
- **Bastion Host** for secure cluster access

## 🔄 CI/CD (GitHub Actions)

On every push to `master`:
1. Builds the Docker image
2. Authenticates to AWS via OIDC (no long-lived credentials)
3. Pushes the image to Amazon ECR

## ☸️ Kubernetes

### Manifests

| Resource | Description |
|---|---|
| Deployment | Application workload |
| Service | Internal cluster networking |
| Ingress | External traffic routing via ingress-nginx / AWS ALB |
| Secret | Sensitive environment variables |

### Helm Chart

Custom Helm chart located at `k8s/charts/devops-lab` with support for:
- Configurable replicas
- Custom image registry and tag
- Environment variables via Secrets
- Liveness and Readiness probes
- Ingress configuration

### Health Checks

The application exposes a `/health` endpoint that checks the database connectivity, integrated with Kubernetes Liveness and Readiness probes to ensure the pod only receives traffic when the database is available.

### Sealed Secrets

Sensitive Kubernetes Secrets are encrypted using Sealed Secrets, allowing them to be safely committed to the repository.

## 🌐 DNS (AWS)

- **External DNS** automatically manages Route 53 records based on Ingress annotations
- **TLS via ACM** is planned but requires a registered domain for certificate validation. The infrastructure and IAM configuration are already in place

## 🔐 Security & Access Control

- EKS authentication via AWS IAM using API mode
- RBAC configured via `aws-auth` to allow additional IAM users to interact with the cluster
- GitHub Actions authenticates to AWS via OIDC roles — no static credentials stored

## 🖥️ Configuration Management (Ansible)

- Ansible roles used to configure PostgreSQL
- Vagrant used for local testing of Ansible playbooks before applying to cloud infrastructure
