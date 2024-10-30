module "kms" {
  # Only create a KMS Key if the user chooses to encrypt GKE secrets
  for_each = var.cluster.encrypt_gke_secrets ? local.regions : []

  source  = "terraform-google-modules/kms/google"
  version = "~> 3.2"

  project_id         = var.project_id
  location           = each.value
  keyring            = "kr-${each.value}"
  keys               = [var.gke_secrets_kms_key_name]
  set_decrypters_for = [var.gke_secrets_kms_key_name]
  set_encrypters_for = [var.gke_secrets_kms_key_name]

  decrypters = [
    "serviceAccount:${local.gke_service_agent_email}"
  ]
  encrypters = [
    "serviceAccount:${local.gke_service_agent_email}"
  ]

  depends_on = [google_project_service.services]
}
