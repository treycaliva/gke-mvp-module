output "gke_cluster_endpoint" {
  value       = google_container_cluster.standard.endpoint
  description = "The endpoint for accessing the Kubernetes API server"
}

output "gke_cluster_name" {
  value       = google_container_cluster.standard.name
  description = "The name of the deployed GKE cluster"
}

output "gke_node_pool_names" {
  value       = { for key, node_pool_values in var.node_pools : key => google_container_node_pool.primary[key].name }
  description = "The names of the created node pools"
}
