/*
Firewall module inputs. `allow` expects a list of objects:
  [{ protocol = "tcp", ports = ["22"] }, ...]
Each object becomes an `allow` block in the firewall resource.
*/

variable "name" {
  type = string
}

variable "project" {
  type = string
}

variable "network" {
  type = string
}

variable "allow" {
  type = list(object({ protocol = string, ports = list(string) }))
  default = []
}

variable "direction" {
  description = "Firewall direction: INGRESS or EGRESS"
  type        = string
  default     = "INGRESS"
}

variable "source_ranges" {
  description = "Source CIDRs for ingress rules (or destination for egress)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "target_tags" {
  description = "Optional instance tags to apply the rule to"
  type        = list(string)
  default     = []
}
