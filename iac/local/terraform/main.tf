terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.9.0"
    }
  }
}

# Let's configure our local kubectl to use the kind cluster we just created.
resource "local_file" "kind_cluster_config" {
  filename = "echo ${pathexpand("~/.kube/kind-cluster-config.yaml")}"
  content  = trimspace(kind_cluster.default.kubeconfig)
}
