/*
Firewall rule resource: creates a VPC-level firewall rule.

The module accepts a list of `allow` blocks (protocol + ports) and builds
one `google_compute_firewall` resource. `source_ranges` and `target_tags`
control sources and targets. Use this to allow SSH, HTTP, etc. from
specified CIDRs.
*/
resource "google_compute_firewall" "this" {
  # Firewall resource name
  name    = var.name
  project = var.project
  # Parent network (pass module.vpc.self_link)
  network = var.network

  # Build allow blocks dynamically from var.allow, a list of objects
  dynamic "allow" {
    for_each = var.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  # Direction: INGRESS or EGRESS
  direction     = var.direction
  # CIDR ranges allowed (for ingress) or targeted (for egress)
  source_ranges = var.source_ranges
  # Optional target tags to narrow the rule to instances tagged with these
  target_tags   = var.target_tags
}
