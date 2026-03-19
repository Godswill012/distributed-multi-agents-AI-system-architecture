# cloud-nat module

Purpose
- Create a Cloud NAT attached to a Cloud Router to provide outbound internet access
  for private instances (no external IP).

Inputs
- `name`, `project`, `router`, `region`, `nat_ip_allocate_option`, `source_subnetwork_ip_ranges_to_nat`, `min_ports_per_vm`.

Outputs
- `name` (nat resource name).

Example
```
module "nat" {
  source = "../../modules/cloud-nat"
  name   = "dev-nat"
  project = var.project
  router = module.router.name
  region = var.region
}
```
