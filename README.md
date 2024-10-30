# GKE MVP Module

This Terraform module provisions a minimum viable Google Kubernetes Engine (GKE) environment on Google Cloud, including a VPC network, Cloud NAT instance, subnets, service accounts, and a GKE Standard cluster.

The module is designed to be flexible and configurable, allowing you to customize the deployment to meet your specific requirements.

An example is provided in the [examples directory](examples/standard-cluster). This example provides an implementation example and a sample validation.

## Features
- Creates a VPC network with configurable subnets.
- Provisions service accounts for GKE cluster and nodes.
- Deploys a GKE Standard cluster with customizable settings (zonal or regional, location, node pools, etc.)
- Optionally enables GKE secrets encryption using Cloud KMS.
- Note on **Firewall Rules:** The module allows Google Cloud to manage the necessary firewall rules for the GKE cluster. This ensures that the required rules are created and maintained automatically, reducing the risk of misconfigurations.

## Prerequisites
- Terraform version: >= 1.9.8
- Google Cloud Platform provider version: >= 6.8.0
- A GCP project and access with the following roles available to either the user or a useable service account:
    - roles/container.admin
    - roles/compute.networkAdmin
    - roles/cloudkms.admin
    - roles/iam.serviceAccountAdmin

## Usage
1. **Define Variable:** Add a `.tfvars` file using the `variables.tf` as a guide.
2. **Initialize Terraform:** Run `terraform init` to initialize the working directory.
3. **Apply the Configuration:** Run `terraform apply` to create the resources.
4. **Verify Deployment:** Use the Google Cloud Console or `gcloud` command-line tool to verify the successful creation of the VPC, subnets, service accounts, and GKE cluster.

## Additional assumptions
- `constraints/compute.skipDefaultNetworkCreation` Org-policy has been set, `skip_default_network` creation has been applied on project creation, or the default network has been deleted.

<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.9.8 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 6.8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.8.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_router"></a> [cloud\_router](#module\_cloud\_router) | terraform-google-modules/cloud-router/google | ~> 6.0 |
| <a name="module_gke"></a> [gke](#module\_gke) | ./modules/gke | n/a |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-google-modules/kms/google | ~> 3.2 |
| <a name="module_service_accounts"></a> [service\_accounts](#module\_service\_accounts) | terraform-google-modules/service-accounts/google | 4.4.1 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | 9.3.0 |

## Resources

| Name | Type |
|------|------|
| [google_project_service.services](https://registry.terraform.io/providers/hashicorp/google/6.8.0/docs/resources/project_service) | resource |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/6.8.0/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Configuration for the GKE cluster.<br/><br/>  - **name**: The name of the GKE cluster.<br/>  - **type**: Type of cluster to deploy. Values: zonal or regional<br/>  - **location**: The region or zone where the GKE cluster will be created.<br/>  - **encrypt\_gke\_secrets**: If set to true, the module will create a KMS Key and use it to enable Secret encryption in GKE.<br/>  - **master\_ip\_cidr\_range**: The IP address range for the cluster master in CIDR notation.<br/><br/>  - **node\_pools**: Creates node pools for the cluster. Required config items include: node\_count, machine\_type, disk\_size\_gb, disk\_type. Additionally, you can enable autoscaling using autoscaling\_enabled and providing values for the min and max node counts. | <pre>object({<br/>    name                 = string<br/>    type                 = string<br/>    location             = string<br/>    encrypt_gke_secrets  = optional(bool, false)<br/>    master_ip_cidr_range = string<br/><br/>    node_pools = map(object({<br/>      node_count   = number<br/>      machine_type = string<br/>      preemptible  = optional(bool, true)<br/>      disk_size_gb = number<br/>      disk_type    = string<br/>      image_type   = optional(string, "COS_CONTAINERED")<br/><br/>      autoscaling_enabled = optional(bool, false)<br/>      min_node_count      = optional(number, 1)<br/>      max_node_count      = optional(number, 5)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Configuration for the Virtual Private Cloud (VPC) network.<br/><br/>  - **vpc\_name**: The name of the VPC network.<br/>  - **subnets**: A list of subnets within the VPC.<br/>    - **name**: The name of the subnet.<br/>    - **ip\_cidr\_range**: The IP address range of the subnet in CIDR notation.<br/>    - **region**: The region where the subnet will be created.<br/>    - **private\_google\_access**: Whether to enable Private Google Access for the subnet. Defaults to true.<br/>    - **flow\_logs**: Whether to enable VPC flow logs for the subnet. Defaults to false.<br/>    - **secondary\_ranges**: A list of secondary IP ranges for the subnet.<br/>        - **range\_name**: The name of the secondary range.<br/>        - **ip\_cidr\_range**: The IP address range of the secondary range in CIDR notation. | <pre>object({<br/>    vpc_name = string<br/>    mtu      = optional(number, 1460)<br/><br/>    subnets = list(object({<br/>      name                  = string<br/>      ip_cidr_range         = string<br/>      region                = string<br/>      private_google_access = optional(bool, true)<br/>      flow_logs             = optional(bool, false)<br/><br/>      secondary_ranges = list(object({<br/>        range_name    = string<br/>        ip_cidr_range = string<br/>      }))<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the Google Cloud Project where resources will be deployed. | `string` | n/a | yes |
| <a name="input_connect_gateway_admins"></a> [connect\_gateway\_admins](#input\_connect\_gateway\_admins) | A set of Google Cloud IAM members who will be granted the a Cluster Admin role on the Connect gateway. | `set(string)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_create_cloud_nat_instance"></a> [create\_cloud\_nat\_instance](#input\_create\_cloud\_nat\_instance) | Allow for the creation of a Cloud NAT and Cloud Router instances along side the Private Cluster to allow for outbound internet access. | `bool` | `true` | no |
| <a name="input_gke_cluster_service_account_name"></a> [gke\_cluster\_service\_account\_name](#input\_gke\_cluster\_service\_account\_name) | The name of the service account used by the Google Kubernetes Engine (GKE) cluster. | `string` | `"gke-sa"` | no |
| <a name="input_gke_secrets_kms_key_name"></a> [gke\_secrets\_kms\_key\_name](#input\_gke\_secrets\_kms\_key\_name) | The name of the KMS Key to create for encrypting GKE secrets | `string` | `"gke-secrets"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gke_cluster_endpoints"></a> [gke\_cluster\_endpoints](#output\_gke\_cluster\_endpoints) | The endpoint for accessing the Kubernetes API server |
| <a name="output_gke_cluster_name"></a> [gke\_cluster\_name](#output\_gke\_cluster\_name) | The name of the deployed GKE cluster |
| <a name="output_gke_node_pool_names"></a> [gke\_node\_pool\_names](#output\_gke\_node\_pool\_names) | The names of the created node pools |
| <a name="output_kms_key_info"></a> [kms\_key\_info](#output\_kms\_key\_info) | Information about the KMS key used for encrypting GKE secrets (if enabled) |
| <a name="output_service_account_emails"></a> [service\_account\_emails](#output\_service\_account\_emails) | The email addresses of the created service accounts |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Created subnets |
| <a name="output_vpc_network_name"></a> [vpc\_network\_name](#output\_vpc\_network\_name) | The name of the VPC network |
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->
