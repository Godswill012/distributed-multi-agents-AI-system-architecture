# Terraform modules

This document describes the Terraform modules under `infrastructure/modules`.

Modules included
- `vpc` — creates a custom-mode VPC network.
- `subnet` — creates a regional subnetwork and optional secondary IP ranges.
- `firewall` — creates VPC-level firewall rules with dynamic `allow` blocks.
- `cloud-router` — creates a regional Cloud Router for NAT/peering.
- `cloud-nat` — creates a Cloud NAT attached to a router for private egress.
- `gke` — creates a GKE cluster with node pool(s), Workload Identity, and private cluster options.

Quick usage example (environment `main.tf`):

module "vpc" {
  source  = "../../modules/vpc"
  name    = "dev-vpc"
  project = var.project
}

module "subnet" {
  source              = "../../modules/subnet"
  name                = "dev-subnet"
  project             = var.project
  region              = var.region
  network             = module.vpc.self_link
  ip_cidr_range       = "10.10.0.0/20"
  secondary_ip_ranges = [
    { range_name = "pods-range" , ip_cidr_range = "10.10.8.0/21" },
    { range_name = "services-range" , ip_cidr_range = "10.10.16.0/24" },
  ]
}

module "gke" {
  source                        = "../../modules/gke"
  name                          = "dev-gke"
  project                       = var.project
  region                        = var.region
  network                       = module.vpc.self_link
  subnetwork                    = module.subnet.self_link
  cluster_secondary_range_name  = "pods-range"
  services_secondary_range_name = "services-range"
  enable_workload_identity      = true
  enable_private_cluster        = true
}

Module summaries

vpc
- Inputs: `name`, `project`, `description`, `routing_mode`.
- Outputs: `name`, `self_link`.
- Purpose: central VPC for subnetworks and cloud resources.

subnet
- Inputs: `name`, `project`, `region`, `network`, `ip_cidr_range`, `private_ip_google_access`, `secondary_ip_ranges`.
- Outputs: `name`, `self_link`.
- Purpose: create regional subnetwork(s) and optional secondary IP ranges used by GKE IP aliasing.

firewall
- Inputs: `name`, `project`, `network`, `allow` (list of {protocol, ports}), `direction`, `source_ranges`, `target_tags`.
- Outputs: `name`.
- Purpose: define VPC firewall rules with flexible `allow` blocks.

cloud-router
- Inputs: `name`, `project`, `network`, `region`, `bgp_asn`.
- Outputs: `name`.
- Purpose: create a Cloud Router required for NAT or hybrid connectivity.

cloud-nat
- Inputs: `name`, `project`, `router`, `region`, `nat_ip_allocate_option`, `source_subnetwork_ip_ranges_to_nat`, `min_ports_per_vm`.
- Outputs: `name`.
- Purpose: provide egress for private instances (e.g., private GKE nodes) via NAT.

gke
- Inputs: many controls including `name`, `project`, `region`, `network`, `subnetwork`, `cluster_secondary_range_name`, `services_secondary_range_name`, node pool settings, `enable_workload_identity`, `workload_identity_k8s_sa`, `enable_private_cluster`, `enable_private_endpoint`, `master_authorized_networks`, `node_service_account_roles`.
- Outputs: `cluster_name`, `cluster_endpoint`, `cluster_self_link`, `node_pool_name`, `node_service_account_email`.
- Purpose: create a production-capable GKE cluster: IP aliasing, optional private nodes, workload identity, and separate managed node pool with autoscaling.

Notes and next steps
- Use `infrastructure/environments/dev/terraform.tfvars.example` to set `project` and `region`.
- To enable remote state, copy `backend.tf.example` to `backend.tf` and set the GCS bucket.
- After `terraform apply` completes for the cluster, enable the Kubernetes provider and apply resources using the example files under `infrastructure/environments/dev/k8s`.
