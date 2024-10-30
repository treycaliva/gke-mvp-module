variable "project_id" {
  type        = string
  description = "Project ID for deployment"
}

variable "fleet_project_id" {
  type        = string
  description = "Project ID for deployment"
  default     = ""
}

variable "cluster_name" {
  type = string
}

variable "cluster_type" {
  type    = string
  default = "zonal"
  validation {
    condition     = contains(["zonal", "regional"], var.cluster_type)
    error_message = "Cluster type must be either 'zonal' or 'regional'."
  }
}

variable "region" {
  type    = string
  default = ""
  validation {
    condition = (
      var.cluster_type == "regional" ? contains(data.google_compute_regions.available.names, var.region) : true
    )
    error_message = "Region must be a valid GCP region (e.g., 'us-central1') when cluster_type is 'regional'."
  }
}

variable "zone" {
  type = string
  validation {
    condition = (
      var.cluster_type == "regional" ? contains(data.google_compute_zones.available.names, var.zone) : true
    )
    error_message = "Zone must be a valid GCP zone (e.g., 'us-central1-a') when cluster_type is 'zonal'."
  }
}

variable "node_locations" {
  type        = list(string)
  description = "List of zones for node pools in regional cluster"
  default     = []
}

variable "node_pools" {
  type = map(object({
    node_count   = number
    machine_type = string
    preemptible  = optional(bool, true)
    disk_size_gb = number
    disk_type    = string
    image_type   = optional(string, "COS_CONTAINERED")

    autoscaling_enabled = optional(bool, false)
    min_node_count      = optional(number, 1)
    max_node_count      = optional(number, 5)
  }))

  description = <<EOD
  Configuration for cluster node pools.

  - **node_pools**: Creates node pools for the cluster. Required config items include: node_count, machine_type, disk_size_gb, disk_type.
  EOD
}

variable "release_channel" {
  type    = string
  default = "REGULAR"
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "cluster_secondary_range_name" {
  type = string
}

variable "services_secondary_range_name" {
  type = string
}

variable "master_ip_cidr_range" {
  type = string
}

variable "connect_gateway_admins" {
  type    = set(string)
  default = [""]
}

variable "encrypt_gke_secrets" {
  type    = bool
  default = true
}

variable "gke_secrets_kms_key_name" {
  type = string
  validation {
    condition = (
      var.encrypt_gke_secrets ? can(regex("^projects/[^/]+/locations/[^/]+/keyRings/[^/]+/cryptoKeys/[^/]+$", var.gke_secrets_kms_key_name)) : true
    )
    error_message = "The gke_secrets_kms_key_name must be a valid KMS key resource ID when encrypt_gke_secrets is true."
  }
}

variable "enable_required_apis" {
  type        = bool
  description = "If set to true, the network module will enable the Compute and DNS APIs within this project."
  default     = true
}

variable "enable_connect_gateway" {
  type    = bool
  default = true
}

variable "gke_service_account" {
  type = string
}
