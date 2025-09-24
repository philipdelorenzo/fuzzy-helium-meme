output "kind_kubeconfig" {
  description = "The kubeconfig for the kind cluster."
  value       = kind_cluster.default.kubeconfig
  sensitive   = true # It's good practice to mark this as sensitive
}
