# Full access to Connect Gateway.
resource "google_project_iam_member" "connect-gateway-editor" {
  for_each = var.connect_gateway_admins

  project = var.project_id
  role    = "roles/gkehub.gatewayEditor"
  member  = "user:${each.value}"
}

# Read-only access to Fleets and related resources.
resource "google_project_iam_member" "connect-gateway-viewers" {
  for_each = var.connect_gateway_admins

  project = var.project_id
  role    = "roles/gkehub.viewer"
  member  = "user:${each.value}"
}

# Allows full access to Kuberentes API objects inside GKE Clusters.
resource "google_project_iam_member" "kubernetes-engine-developer" {
  for_each = var.connect_gateway_admins

  project = var.project_id
  role    = "roles/container.developer"
  member  = "user:${each.value}"
}
