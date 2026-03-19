# cloud-router module

Purpose
- Create a regional Cloud Router required for Cloud NAT and BGP peering.

Inputs
- `name`, `project`, `network`, `region`, `bgp_asn`.

Outputs
- `name` (router name).

Example
```
module "router" {
  source = "../../modules/cloud-router"
  name   = "dev-router"
  project = var.project
  region = var.region
  network = module.vpc.self_link
}
```
