terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.9"
    }
  }
}

provider "kind" {}

resource "kind_cluster" "main" {
  name = "de-cluster"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
    }
  }
}

output "cluster_name" {
  value = kind_cluster.main.name
}

output "kubeconfig" {
  value     = kind_cluster.main.kubeconfig
  sensitive = true
}