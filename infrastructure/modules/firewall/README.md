# firewall module

Purpose
- Create VPC-level firewall rules with flexible allow blocks.

Inputs
- `name`, `project`, `network`, `allow` (list of objects {protocol, ports}), `direction`, `source_ranges`, `target_tags`.

Outputs
- `name` (created firewall resource name).

Example
```
module "firewall" {
  source = "../../modules/firewall"
  name   = "allow-ssh-http"
  project = var.project
  network = module.vpc.self_link
  allow = [ { protocol = "tcp", ports = ["22"] }, { protocol = "tcp", ports = ["80","443"] } ]
}
```
