# We need a cluster to build locally and test our services
resource "kind_cluster" "default" {
  name       = "helium-cluster"
  node_image = "kindest/node:v1.27.1"
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    node {
      role = "control-plane"
      extra_port_mappings {
        container_port = 8080
        host_port      = 8080
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
        protocol       = "TCP"
      }
    }
    node {
      role = "worker"
    }
    node {
      role = "worker2"
    }
  }
}
