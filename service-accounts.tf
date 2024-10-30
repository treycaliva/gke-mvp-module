module "service_accounts" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "4.4.1"

  project_id   = var.project_id
  display_name = "GKE Service Account - Terraform-managed"
  names        = [var.gke_cluster_service_account_name]

  # This is the least privileged role for the Node Service Accounts
  project_roles = [
    "${var.project_id}=>roles/container.defaultNodeServiceAccount"
  ]

  depends_on = [google_project_service.services]
}
