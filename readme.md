# Airflow on Kubernetes with Kind, Terraform, Helm, and Argo CD

## Overview

This project demonstrates how to deploy **Apache Airflow 3.0.2** on a local Kubernetes cluster using modern GitOps and Infrastructure as Code practices.

The infrastructure is provisioned with **Terraform**, the Kubernetes cluster is created using **Kind**, Airflow is deployed through the official **Helm Chart**, and **Argo CD** is responsible for continuous deployment.

The deployment uses the **KubernetesExecutor**, allowing each Airflow task to run inside its own Kubernetes Pod.

---

## Architecture

```
Terraform
    │
    ▼
Kind Cluster
    │
    ▼
Argo CD
    │
    ▼
Airflow Helm Chart
    │
    ▼
Kubernetes Cluster
        │
        ├── Scheduler
        ├── Webserver
        ├── PostgreSQL
        └── Task Pods (KubernetesExecutor)
```

GitSync periodically pulls DAGs from a GitHub repository, allowing DAG updates without rebuilding the Airflow Docker image.

---

# Technologies

* Terraform
* Kind
* Kubernetes
* Helm
* Argo CD
* Apache Airflow 3.0.2
* PostgreSQL
* GitSync

---

# Infrastructure

Terraform creates a local Kind cluster.

```text
terraform/
│
├── main.tf
```

The cluster contains a single control-plane node which is sufficient for local development.

### Create the cluster

```bash
terraform init
terraform apply
```

---

# Airflow Deployment

Airflow is installed using the official Helm Chart.

The deployment uses:

* KubernetesExecutor
* PostgreSQL
* GitSync
* Kubernetes Secrets
* Official Airflow Docker Image

---

# Configuration

The deployment is configured using `values.yml`.

## Executor

```yaml
executor: KubernetesExecutor
```

Every Airflow task is executed as an independent Kubernetes Pod instead of a long-running worker.

Advantages:

* Better scalability
* Better resource isolation
* No Celery workers required
* Native Kubernetes scheduling

---

## Airflow Version

```yaml
airflowVersion: "3.0.2"
```

The Helm chart deploys Airflow version **3.0.2**.

---

## Custom Docker Image

```yaml
images:
  airflow:
    repository: hisham21113/hr-platform
    tag: v1
```

A custom Docker image is used instead of the default Apache Airflow image.

This image should contain:

* Python dependencies
* Custom libraries
* Airflow providers
* Internal packages

Since DAGs are synchronized using GitSync, the image only contains application dependencies.

---

## Components

```yaml
webserver:
  replicas: 1

scheduler:
  replicas: 1

triggerer:
  replicas: 0

workers:
  replicas: 0
```

### Webserver

Provides the Airflow UI.

### Scheduler

Schedules DAG runs and submits task Pods.

### Triggerer

Disabled because deferrable operators are not used.

### Workers

Disabled because KubernetesExecutor launches task Pods dynamically.

---

## PostgreSQL

```yaml
postgresql:
  enabled: true
```

PostgreSQL stores:

* DAG metadata
* Task states
* Connections
* Variables
* Users

---

## Redis

```yaml
redis:
  enabled: false
```

Redis is unnecessary because KubernetesExecutor does not require Celery.

---

## Helm Jobs

```yaml
createUserJob:
  useHelmHooks: false

migrateDatabaseJob:
  useHelmHooks: false
```

These jobs are executed as normal Kubernetes resources instead of Helm hooks.

This configuration works better with Argo CD because Argo CD manages all resources declaratively.

---

## Service Account

```yaml
serviceAccount:
  create: true
```

Creates a dedicated Kubernetes ServiceAccount for Airflow Pods.

---

## Logs

```yaml
logs:
  persistence:
    enabled: false
```

Persistent log storage is disabled.

Logs exist only during the Pod lifetime, which is acceptable for local development.

---

# GitSync

```yaml
dags:
  persistence:
    enabled: false

  gitSync:
    enabled: true
```

GitSync periodically clones the DAG repository.

```yaml
repo: https://github.com/USERNAME/REPO.git
branch: main
subPath: dags
period: 30s
```

Every 30 seconds GitSync checks the GitHub repository for changes.

If a new commit exists:

* Pull latest code
* Update DAG directory
* Scheduler automatically detects new DAGs

This removes the need to rebuild Docker images when DAGs change.

---

# Environment Variables

```yaml
env:
```

### Disable Example DAGs

```yaml
AIRFLOW__CORE__LOAD_EXAMPLES=False
```

Prevents Airflow from loading example DAGs.

---

### Hide Configuration

```yaml
AIRFLOW__WEBSERVER__EXPOSE_CONFIG=False
```

Prevents exposing sensitive configuration through the Airflow UI.

---

### Time Zone

```yaml
TZ=Africa/Cairo
```

Configures container time zone.

---

# Secrets

```yaml
envFromSecrets:
  - airflow-env
```

Sensitive configuration such as:

* Database credentials
* API Keys
* Cloud credentials
* Fernet Key

should be stored inside Kubernetes Secrets instead of the Helm values file.

---

# GitOps with Argo CD

Argo CD continuously watches the Git repository.

Whenever `values.yml` changes:

1. Detect the new commit.
2. Compare the desired state with the cluster.
3. Apply the changes automatically.
4. Keep the cluster synchronized with Git.

---

# Project Structure

```text
.
├── terraform/
│   └── main.tf
│
├── helm/
│   └── airflow/
│       └── values.yml
│
├── argocd/
│   └── airflow-application.yml
│
└── README.md
```

---

# Deployment Workflow

```
Terraform
      │
      ▼
Creates Kind Cluster
      │
      ▼
Install Argo CD
      │
      ▼
Create Airflow Application
      │
      ▼
Argo CD installs Helm Chart
      │
      ▼
Airflow starts
      │
      ▼
GitSync downloads DAGs
      │
      ▼
Scheduler discovers DAGs
      │
      ▼
Tasks run as Kubernetes Pods
```

---

# Features

* Infrastructure as Code using Terraform
* Local Kubernetes cluster using Kind
* GitOps deployment with Argo CD
* Airflow deployed via Helm
* KubernetesExecutor
* Automatic DAG synchronization with GitSync
* Secrets managed using Kubernetes Secrets
* PostgreSQL metadata database
* Custom Airflow Docker image
* Ready for CI/CD integration
