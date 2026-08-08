variable "cluster_name" {
  description = "The name of the KinD cluster"
  type        = string
  default     = "de-cluster"
}

variable "node_image" {
  description = "The Docker image to use for nodes (Kubernetes version)"
  type        = string
  default     = "kindest/node:v1.31.0"
}