# We need a cluster to build locally and test our services
resource "kind_cluster" "default" {
    name = "helium-cluster"
    node_image = "kindest/node:v1.27.1"
    kind_config  {
        kind = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"
        node {
            role = "control-plane"
        }
        node {
            role =  "worker"
        }
        node {
            role =  "worker2"
        }
    }
}
