resource "google_container_node_pool" "primary" {
  for_each = var.node_pools

  project    = var.project_id
  name       = "${each.key}-node-pool"
  location   = var.cluster_type == "zonal" ? var.zone : var.region
  cluster    = google_container_cluster.standard.name
  node_count = each.value.node_count

  # Enable Private Nodes
  network_config {
    enable_private_nodes = true
  }

  # Enable autoscaling
  dynamic "autoscaling" {
    for_each = each.value.autoscaling_enabled ? [1] : []

    content {
      min_node_count = each.value.min_node_count
      max_node_count = each.value.max_node_count
    }
  }

  # Node configuration
  node_config {
    preemptible  = each.value.preemptible
    machine_type = each.value.machine_type

    disk_size_gb = each.value.disk_size_gb
    disk_type    = each.value.disk_type
    image_type   = each.value.image_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = var.gke_service_account
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    tags = [
      "gke-nodes",
    ]

    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = false
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  # Disabled for now. Can be enabled for GPU workloads
  queued_provisioning {
    enabled = false
  }
}
