resource "google_project_service" "services" {
  for_each = { for key, service in local.services : key => service if service != null }

  project = var.project_id
  service = each.value

  timeouts {
    create = "5m"
    update = "5m"
  }

  disable_on_destroy = false
}
