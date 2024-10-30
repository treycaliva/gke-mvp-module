module "gke_mvp" {
  source     = "../../"
  project_id = var.project_id

  network = var.network
  cluster = var.cluster

  connect_gateway_admins = []
}
