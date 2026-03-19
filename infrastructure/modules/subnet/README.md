# subnet module

Purpose
- Create a regional subnetwork and optional secondary IP ranges (used by GKE IP aliasing).

Inputs
- `name`, `project`, `region`, `network`, `ip_cidr_range` (primary), `private_ip_google_access` (bool), `secondary_ip_ranges` (list of { range_name, ip_cidr_range }).

Outputs
- `name`, `self_link` (pass `self_link` into the GKE module's `subnetwork`).

Example
```
module "subnet" {
  source = "../../modules/subnet"
  name   = "dev-subnet"
  project = var.project
  region = var.region
  network = module.vpc.self_link
  ip_cidr_range = "10.10.0.0/20"
  secondary_ip_ranges = [{range_name="pods-range", ip_cidr_range="10.10.8.0/21"}]
}
```
