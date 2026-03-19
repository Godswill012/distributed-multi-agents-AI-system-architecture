# vpc module

Purpose
- Create a custom-mode VPC network (no auto subnet creation).

Inputs (variables)
- `name` (string): network name
- `project` (string): GCP project id
- `description` (string): optional
- `routing_mode` (string): REGIONAL or GLOBAL

Outputs
- `name` (string): network name
- `self_link` (string): network self link (useful when passing to other resources)

Example
```
module "vpc" {
  source  = "../../modules/vpc"
  name    = "dev-vpc"
  project = var.project
}
```
