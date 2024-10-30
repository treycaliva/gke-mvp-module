module "gke" {
  for_each = local.regions
  source   = "./modules/gke"

  project_id           = var.project_id
  fleet_project_id     = var.project_id
  enable_required_apis = true

  cluster_name = var.cluster.name
  cluster_type = var.cluster.type
  region       = var.cluster.type == "regional" ? var.cluster.location : ""
  zone         = var.cluster.type == "zonal" ? var.cluster.location : ""

  network    = module.vpc.network_id
  subnetwork = { for subnet in module.vpc.subnets : subnet.region => subnet.id if subnet.region == each.value }[each.value]

  node_pools = var.cluster.node_pools

  master_ip_cidr_range          = var.cluster.master_ip_cidr_range
  cluster_secondary_range_name  = "secondary-range-pods"
  services_secondary_range_name = "secondary-range-services"

  encrypt_gke_secrets      = var.cluster.encrypt_gke_secrets
  gke_secrets_kms_key_name = var.cluster.encrypt_gke_secrets ? module.kms[each.value].keys[var.gke_secrets_kms_key_name] : ""

  gke_service_account    = module.service_accounts.service_accounts_map[var.gke_cluster_service_account_name].email
  connect_gateway_admins = var.connect_gateway_admins

  depends_on = [google_project_service.services]
}
