resource "google_container_cluster" "standard" {
  project             = var.project_id
  deletion_protection = false

  name     = var.cluster_name
  location = var.cluster_type == "zonal" ? var.zone : var.region

  # Joins cluster to a Fleet Project to allow for enabling Connect Gateway
  dynamic "fleet" {
    for_each = [var.fleet_project_id]

    content {
      project = fleet.value
    }
  }

  release_channel {
    channel = var.release_channel
  }

  # Default Node Pool is created and immediately deleted. This allows us to decouple the cluster and the node pools.
  remove_default_node_pool = true
  initial_node_count       = 1

  network           = var.network
  subnetwork        = var.subnetwork
  datapath_provider = "ADVANCED_DATAPATH" # Enabling Dataplane V2

  # Defaulting all clusters to private clusters
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master_ip_cidr_range
  }

  # Block omits `cidr_blocks` to disallow external access
  master_authorized_networks_config {
  }

  addons_config {
    # Enables NodeLocal DNSCache - improves DNS lookup latency
    dns_cache_config {
      enabled = true
    }

    # Enables GCSFuse CSI Driver - Allows the usage of a GCS bucket as volumes
    gcs_fuse_csi_driver_config {
      enabled = true
    }
  }

  # Enables the Cost Allocation feature - Sends additional information to BigQuery Cloud Billing export to help show GKE cost allocation by namespace
  cost_management_config {
    enabled = true
  }

  # Optional enablement of GKE secret encryption
  dynamic "database_encryption" {
    for_each = var.encrypt_gke_secrets ? [1] : []

    content {
      key_name = var.gke_secrets_kms_key_name
      state    = "ENCRYPTED"
    }
  }

  # Enables the use of Cloud DNS as the in-cluster DNS provider
  dns_config {
    cluster_dns       = "CLOUD_DNS"
    cluster_dns_scope = "CLUSTER_SCOPE"
  }

  # Enables the use of Gateway API in the cluster
  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  # Configuration of cluster IP allocation for VPC-native clusters
  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
    stack_type                    = "IPV4"
  }

  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
    ]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "STORAGE",
      "POD",
      "DEPLOYMENT",
      "STATEFULSET",
      "DAEMONSET",
      "HPA",
      "CADVISOR",
      "KUBELET",
    ]

    # Enables additional metrics and Hubble Relay - Dataplane V2
    advanced_datapath_observability_config {
      enable_metrics = true
      enable_relay   = true
    }

    # Enables Google Managed Prometheus
    managed_prometheus {
      enabled = true
    }
  }

  # Enables Secret Manager add-on for cluster
  secret_manager_config {
    enabled = true
  }

  # Enables Security Posture reporting in GCP Console
  security_posture_config {
    mode               = "BASIC"
    vulnerability_mode = "VULNERABILITY_BASIC"
  }

  # Enables VPA in cluster
  vertical_pod_autoscaling {
    enabled = true
  }

  # Enables Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}
