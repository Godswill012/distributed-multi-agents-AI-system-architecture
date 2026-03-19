module "vpc" {
  source    = "../../modules/vpc"
  name      = "dev-vpc"
  project   = var.project
}

module "subnet" {
  source                        = "../../modules/subnet"
  name                          = "dev-subnet"
  project                       = var.project
  region                        = var.region
  network                       = module.vpc.self_link
  ip_cidr_range                 = "10.10.0.0/20"
  secondary_ip_ranges           = [
    { range_name = "pods-range" , ip_cidr_range = "10.20.0.0/16" },
    { range_name = "services-range" , ip_cidr_range = "10.30.0.0/24" },
  ]
  private_ip_google_access = var.private_ip_google_access
}

module "router" {
  source  = "../../modules/cloud-router"
  name    = "dev-router"
  project = var.project
  region  = var.region
  network = module.vpc.self_link
}

module "nat" {
  source  = "../../modules/cloud-nat"
  name    = "dev-nat"
  project = var.project
  router  = module.router.name
  region  = var.region
}

module "firewall" {
  source = "../../modules/firewall"
  name   = "allow-ssh-http"
  project = var.project
  network = module.vpc.self_link
  allow = [
    { protocol = "tcp" , ports = ["22"] },
    { protocol = "tcp" , ports = ["80","443"] },
  ]
}

module "gke" {
  source   = "../../modules/gke"
  name     = "dev-gke"
  project  = var.project
  region   = var.region
  network  = module.vpc.self_link
  subnetwork = module.subnet.self_link
  cluster_secondary_range_name  = "pods-range"
  services_secondary_range_name = "services-range"
  enable_workload_identity = true
  deletion_protection = var.deletion_protection
  # node pool settings
  node_machine_type = "e2-medium"
  node_pool_initial_node_count = 1
  node_pool_min_count = 1
  node_pool_max_count = 3
  # grant recommended IAM roles to the node service account (adjust as needed)
  node_service_account_roles = [
    "roles/container.nodeServiceAccount",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.objectViewer",
  ]
  # master authorized networks (empty = none)
  master_authorized_networks = []
  # Enable a private cluster where nodes have no public IPs
  enable_private_cluster = true
  # Keep private endpoint off (API endpoint will have a public endpoint unless changed)
  enable_private_endpoint = false
  # Optionally set the k8s service account (namespace/name) to bind for Workload Identity
  workload_identity_k8s_sa = ""
}
