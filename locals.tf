locals {
  services = {
    compute = "compute.googleapis.com"
    dns     = "dns.googleapis.com"
    kms     = var.cluster.encrypt_gke_secrets ? "cloudkms.googleapis.com" : null
  }

  regions = toset([for subnet in var.network.subnets : subnet.region])

  gke_service_agent_email = "service-${data.google_project.this.number}@container-engine-robot.iam.gserviceaccount.com"

  subnets = [for subnet in var.network.subnets : {
    subnet_name           = "${subnet.name}-${subnet.region}"
    subnet_ip             = subnet.ip_cidr_range
    subnet_region         = subnet.region
    subnet_private_access = subnet.private_google_access
    subnet_flow_logs      = subnet.flow_logs
  }]

  secondary_ranges = { for subnet in var.network.subnets : "${subnet.name}-${subnet.region}" => subnet.secondary_ranges }
}
