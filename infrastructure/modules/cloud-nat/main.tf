/*
Cloud NAT resource: provides egress for private instances that have no
external IPs. It must be associated with a `google_compute_router`.
`nat_ip_allocate_option` controls whether NAT IPs are auto-created or
configured manually.
*/
resource "google_compute_router_nat" "this" {
  # NAT name
  name                               = var.name
  project                            = var.project
  # Router resource name (not self_link) the NAT attaches to
  router                             = var.router
  region                             = var.region
  # How external IPs for the NAT are allocated (AUTO_ONLY or MANUAL_ONLY)
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  # Which subnetwork IP ranges (ALL_SUBNETWORKS_ALL_IP_RANGES, or list)
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat
  # Minimum number of ports per VM allocated by the NAT (controls scale)
  min_ports_per_vm                   = var.min_ports_per_vm
}
