output "gke_cluster_endpoints" {
  value       = { for region, cluster in module.gke : region => cluster.gke_cluster_endpoint }
  description = "The endpoint for accessing the Kubernetes API server"
}

output "gke_cluster_name" {
  value       = { for region, cluster in module.gke : region => cluster.gke_cluster_name }
  description = "The name of the deployed GKE cluster"
}

output "gke_node_pool_names" {
  value       = { for region, cluster in module.gke : region => cluster.gke_node_pool_names }
  description = "The names of the created node pools"
}

output "vpc_network_name" {
  value       = module.vpc.network_name
  description = "The name of the VPC network"
}

output "subnets" {
  value       = module.vpc.subnets
  description = "Created subnets"
}

output "service_account_emails" {
  value       = module.service_accounts.service_accounts_map
  description = "The email addresses of the created service accounts"
}

output "kms_key_info" {
  value = var.cluster.encrypt_gke_secrets ? {
    key_ring = module.kms[var.cluster.location].keyring
    key_name = module.kms[var.cluster.location].keys[0]
  } : null
  description = "Information about the KMS key used for encrypting GKE secrets (if enabled)"
}
