
variable "kubectl_config_path" {
  description = "Path to the kubeconfig file for kubectl to use."
  type        = string
  default     = "~/.kube/kind-cluster-config.yaml"
}
