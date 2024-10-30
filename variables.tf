variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud Project where resources will be deployed."
}

variable "network" {
  type = object({
    vpc_name = string
    mtu      = optional(number, 1460)

    subnets = list(object({
      name                  = string
      ip_cidr_range         = string
      region                = string
      private_google_access = optional(bool, true)
      flow_logs             = optional(bool, false)

      secondary_ranges = list(object({
        range_name    = string
        ip_cidr_range = string
      }))
    }))
  })
  description = <<EOD
  Configuration for the Virtual Private Cloud (VPC) network.

  - **vpc_name**: The name of the VPC network.
  - **subnets**: A list of subnets within the VPC.
    - **name**: The name of the subnet.
    - **ip_cidr_range**: The IP address range of the subnet in CIDR notation.
    - **region**: The region where the subnet will be created.
    - **private_google_access**: Whether to enable Private Google Access for the subnet. Defaults to true.
    - **flow_logs**: Whether to enable VPC flow logs for the subnet. Defaults to false.
    - **secondary_ranges**: A list of secondary IP ranges for the subnet.
        - **range_name**: The name of the secondary range.
        - **ip_cidr_range**: The IP address range of the secondary range in CIDR notation.
EOD
}

variable "create_cloud_nat_instance" {
  type        = bool
  default     = true
  description = "Allow for the creation of a Cloud NAT and Cloud Router instances along side the Private Cluster to allow for outbound internet access."
}

variable "gke_cluster_service_account_name" {
  type        = string
  default     = "gke-sa"
  description = "The name of the service account used by the Google Kubernetes Engine (GKE) cluster."
}

variable "gke_secrets_kms_key_name" {
  type        = string
  default     = "gke-secrets"
  description = "The name of the KMS Key to create for encrypting GKE secrets"
}

variable "cluster" {
  type = object({
    name                 = string
    type                 = string
    location             = string
    encrypt_gke_secrets  = optional(bool, false)
    master_ip_cidr_range = string

    node_pools = map(object({
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
  })

  description = <<EOD
  Configuration for the GKE cluster.

  - **name**: The name of the GKE cluster.
  - **type**: Type of cluster to deploy. Values: zonal or regional
  - **location**: The region or zone where the GKE cluster will be created.
  - **encrypt_gke_secrets**: If set to true, the module will create a KMS Key and use it to enable Secret encryption in GKE.
  - **master_ip_cidr_range**: The IP address range for the cluster master in CIDR notation.

  - **node_pools**: Creates node pools for the cluster. Required config items include: node_count, machine_type, disk_size_gb, disk_type. Additionally, you can enable autoscaling using autoscaling_enabled and providing values for the min and max node counts.
EOD
}

variable "connect_gateway_admins" {
  type        = set(string)
  default     = [""]
  description = "A set of Google Cloud IAM members who will be granted the a Cluster Admin role on the Connect gateway."
}
