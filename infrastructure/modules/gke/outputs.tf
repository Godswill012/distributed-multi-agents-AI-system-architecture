/*
GKE module outputs. These provide the cluster name, endpoint and node pool
details for use by other modules or consumers (for example the k8s provider
or CI scripts that need to interact with the cluster).
*/
output "cluster_name" {
  value = google_container_cluster.this.name
}

output "cluster_endpoint" {
  value = google_container_cluster.this.endpoint
}

output "cluster_self_link" {
  value = google_container_cluster.this.self_link
}

output "node_pool_name" {
  value = google_container_node_pool.primary.name
}

output "node_service_account_email" {
  value = local.node_service_account
}
output "name" { value = google_container_cluster.this.name }
output "endpoint" { value = google_container_cluster.this.endpoint }
