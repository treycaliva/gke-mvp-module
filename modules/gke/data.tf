data "google_project" "this" {
  project_id = var.project_id
}

data "google_compute_regions" "available" {
  project = var.project_id
}

data "google_compute_zones" "available" {
  project = var.project_id
}
