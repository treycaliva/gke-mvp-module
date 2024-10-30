variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in"
}

variable "network" {
  type = object({
    vpc_name = string
    subnets = list(object({
      name                  = string
      ip_cidr_range         = string
      region                = string
      private_google_access = bool
      secondary_ranges = list(object({
        range_name    = string
        ip_cidr_range = string
      }))
    }))
  })
  description = "Network configuration for the GKE cluster."
  default = {
    vpc_name = "gke-network"
    subnets = [
      {
        name                  = "gke-subnet"
        ip_cidr_range         = "10.20.0.0/20"
        region                = "us-south1"
        private_google_access = true
        secondary_ranges = [
          {
            range_name    = "secondary-range-pods"
            ip_cidr_range = "250.20.0.0/14"
          },
          {
            range_name    = "secondary-range-services"
            ip_cidr_range = "250.24.0.0/20"
          },
        ]
      },
    ]
  }
}

variable "cluster" {
  type = object({
    name                 = string
    type                 = string
    location             = string
    encrypt_gke_secrets  = bool
    master_ip_cidr_range = string
    node_pools = map(object({
      node_count          = number
      machine_type        = string
      preemptible         = bool
      disk_size_gb        = number
      disk_type           = string
      image_type          = string
      autoscaling_enabled = optional(bool, false)
      min_node_count      = optional(number, 1)
      max_node_count      = optional(number, 5)
    }))
  })
  description = "Cluster configuration for GKE cluster."
  default = {
    name                 = "gke-mvp"
    type                 = "zonal"
    location             = "us-south1-b"
    encrypt_gke_secrets  = false
    master_ip_cidr_range = "172.32.0.0/28"
    node_pools = {
      primary = {
        node_count          = 3
        machine_type        = "e2-medium"
        preemptible         = false
        disk_size_gb        = 100
        disk_type           = "pd-balanced"
        image_type          = "COS_CONTAINERD"
        autoscaling_enabled = true
      }
    }
  }
}

variable "connect_gateway_admins" {
  type        = list(string)
  description = "List of users allowed to connect and administor the cluster via Connect Gateway."
  default     = []
}
