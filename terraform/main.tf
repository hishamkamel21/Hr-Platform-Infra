resource "kind_cluster" "main" {
  name       = var.cluster_name
  node_image = var.node_image

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    # Control Plane Node
    node {
      role = "control-plane"
    }

    # Worker Node
    node {
      role = "worker"
    }
  }
}