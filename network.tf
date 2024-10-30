# Creates VPC, Subnets, and Secondary IP Ranges for Cluster
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "9.3.0"

  project_id   = var.project_id
  network_name = var.network.vpc_name
  mtu          = var.network.mtu

  subnets          = local.subnets
  secondary_ranges = local.secondary_ranges

  depends_on = [google_project_service.services]
}

# Creates Cloud Router and Cloud NAT for cluster outbound internet connection
module "cloud_router" {
  for_each = var.create_cloud_nat_instance ? local.regions : []

  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"

  name    = "cloud-nat"
  project = var.project_id
  network = module.vpc.network_name
  region  = each.value

  nats = [{
    name                               = "project-nat-gateway"
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

    subnetworks = [
      {
        name = { for subnet in module.vpc.subnets : subnet.region => subnet if subnet.region == each.value }[each.value].id

        source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]
        secondary_ip_range_names = { for subnet in module.vpc.subnets : subnet.region => subnet if subnet.region == each.value }[each.value].secondary_ip_range[*].range_name
      }
    ]
  }]
}
