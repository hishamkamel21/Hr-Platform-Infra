output "cluster_name" {
  description = "The name of the deployed KinD cluster"
  value       = kind_cluster.main.name
}

output "kubeconfig" {
  description = "The kubeconfig to access the cluster"
  value       = kind_cluster.main.kubeconfig
  sensitive   = true
}

output "cluster_endpoint" {
  description = "The Kubernetes API server endpoint"
  value       = kind_cluster.main.endpoint
}