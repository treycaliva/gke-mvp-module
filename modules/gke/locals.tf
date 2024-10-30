locals {
  services = {
    gke            = var.enable_required_apis ? "container.googleapis.com" : null
    connectgateway = var.enable_required_apis ? "connectgateway.googleapis.com" : null
    gkehub         = var.enable_required_apis ? "gkehub.googleapis.com" : null
    gkeconnect     = var.enable_required_apis ? "gkeconnect.googleapis.com" : null
  }
}
