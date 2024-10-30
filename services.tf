resource "google_project_service" "services" {
  # This statement will check to make sure the list of services in locals.tf are required before enabling
  for_each = { for key, service in local.services : key => service if service != null }

  project = var.project_id
  service = each.value

  timeouts {
    create = "5m"
    update = "5m"
  }

  disable_on_destroy = false
}
