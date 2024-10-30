# Example - GKE Standard Cluster
This example creates an implementation of the GKE MVP module. In addition, a sample worload is included to test if the cluster has been deployed successfully.

**Prerequisites:**
- *Install required tools:*
    - `gcloud` CLI
    - `kubectl`
    - `terraform`

This example/module will:
- Ensure required APIs (Compute Engine, DNS, Kubernetes Engine, Connect Gateway, GKE Hub (Fleet), KMS (optional)) are enabled prior to deployment of components.
- Create a VPC and required subnets for deploying a GKE Standard cluster.
- Create a private GKE Standard cluster.
- Optionally create a KMS Keyring and Key for use in encrypting GKE secrets.

## Usage
1. **Complete Remote State File:** A `remote-state.tf` file has been provided in this directory but will need to be completed before running. If you wish to just use local state, you can remove this file.
2. **Define Variable:** Add a `.tfvars` file using the `variables.tf` as a guide.
3. **Initialize Terraform:** Run `terraform init` to initialize the working directory.
4. **Apply the Configuration:** Run `terraform apply` to create the resources.
5. **Verify Deployment:** Use the Google Cloud Console or `gcloud` command-line tool to verify the successful creation of the VPC, subnets, service accounts, and GKE cluster.

## Validation suggestion
Two Kubernetes configuration files are included to provided to validate a working cluster. 

**NOTE:** This validation example assumes you will enable Connect Gateway using the `connect_gateway_admins` variable. This variable allows you to specify a list of IAM identities that can administer Connect Gateway. For example, to allow the user `user@example.com` to administer Connect Gateway:

```terraform
connect_gateway_admins = ["user@example.com"]
```

Steps to validate:
1. Get Connect Gateway cluster credentials
```
gcloud container fleet memberships get-credentials <CLUSTER_NAME> --project <GCP_PROJECT_ID>
```
2. Apply validator config files using kubectl
```
kubectl apply -f validate/
```
3. Get External IP from service 
```
kubectl get service whereami -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

##
Contributor: Trey Caliva <treycaliva@gmail.com>
