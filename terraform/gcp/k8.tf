# Create GKE Cluster
resource "google_container_cluster" "primary" {
  name     = join("-", [var.resource_group_name, "gke"])
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version = var.kubernetes_version
  network = google_compute_network.vnet.name
  # networking_mode = "VPC_NATIVE"
  subnetwork = google_compute_subnetwork.subnet_pod.name
  network_policy {
    enabled = true
    provider = "CALICO"
  }

}

# Create Node Pool with No Autoscaling
resource "google_container_node_pool" "first_node_pool" {
  name       = "ondemand-nodepool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1
  version = var.kubernetes_version

  node_config {
    machine_type = var.aks_node_size
    # other node configuration options
    metadata = {
      ssh-keys = "${var.vm_admin_username}:${var.ssh_public_key}"
    }
  }

}

# Create Node Pool with Autoscaling using Preemptible Nodes
resource "google_container_node_pool" "second_node_pool" {
  name       = "spot-nodepool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.aks_min_node_count
  # initial_node_count = var.aks_min_node_count
  version = var.kubernetes_version

  node_config {
    machine_type = var.aks_node_size_spot
    preemptible  = true
    # other node configuration options
    metadata = {
      ssh-keys = "${var.vm_admin_username}:${var.ssh_public_key}"
    }
  }

  autoscaling {
    min_node_count = var.aks_min_node_count
    max_node_count = var.aks_max_node_count
  }

}


# Output the kubeconfig to a local file
# resource "local_file" "kubeconfig" {
#   depends_on = [google_container_cluster.primary]
#   filename = "./kubeconfig"
#   content  = <<-EOT
# apiVersion: v1
# clusters:
# - cluster:
#     certificate-authority-data: ${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}
#     server: https://${google_container_cluster.primary.endpoint}
#   name: ${google_container_cluster.primary.name}
# contexts:
# - context:
#     cluster: ${google_container_cluster.primary.name}
#     user: ${google_container_cluster.primary.name}
#   name: ${google_container_cluster.primary.name}
# current-context: ${google_container_cluster.primary.name}
# kind: Config
# preferences: {}
# users:
# - name: ${google_container_cluster.primary.name}
#   user:
#     auth-provider:
#       config:
#         cmd-args: config config-helper --format=json
#         cmd-path: gcloud
#         expiry-key: '{.credential.token_expiry}'
#         token-key: '{.credential.access_token}'
#       name: gcp
# - name: auth-gke
#   user:
#     exec:
#       apiVersion: client.authentication.k8s.io/v1beta1
#       command: gke-gcloud-auth-plugin
#       installHint: Install gke-gcloud-auth-plugin for use with kubectl by following
#         https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
#       provideClusterInfo: true
# EOT
# }