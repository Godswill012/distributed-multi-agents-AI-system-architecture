# gke module

Purpose
- Create a GKE cluster with support for IP aliasing, private clusters, Workload Identity,
  and a managed node pool with autoscaling.

Key inputs
- `name`, `project`, `region`, `network`, `subnetwork`.
- `cluster_secondary_range_name`, `services_secondary_range_name` — names of subnet secondary ranges.
- Node pool: `node_machine_type`, `node_pool_initial_node_count`, `node_pool_min_count`, `node_pool_max_count`, `node_service_account_email`.
- `enable_workload_identity`, `workload_identity_k8s_sa` — Workload Identity configuration.
- `enable_private_cluster`, `enable_private_endpoint`, `master_ipv4_cidr` — private cluster options.
- `master_authorized_networks` — list of CIDRs allowed to call the control plane.
- `node_service_account_roles` — list of IAM roles to bind to the node service account.

Outputs
- `cluster_name`, `cluster_endpoint`, `cluster_self_link`, `node_pool_name`, `node_service_account_email`.

Example
```
module "gke" {
  source = "../../modules/gke"
  name   = "dev-gke"
  project = var.project
  region = var.region
  network = module.vpc.self_link
  subnetwork = module.subnet.self_link
  cluster_secondary_range_name  = "pods-range"
  services_secondary_range_name = "services-range"
  enable_workload_identity = true
  enable_private_cluster = true
}
```

Notes
- The module creates a node service account if none is provided and can bind the
  provided IAM roles. Restrict roles to least privilege for production.
