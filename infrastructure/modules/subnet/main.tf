/*
Subnetwork resource: creates a regional subnetwork inside a VPC.

This supports:
 - the primary IP CIDR for VM instances
 - optional `private_ip_google_access` (to allow access to Google APIs privately)
 - dynamic `secondary_ip_range` blocks to create secondary ranges used by
   GKE IP Alias (pods/services) when `secondary_ip_ranges` are provided.
*/
resource "google_compute_subnetwork" "this" {
  # Subnet name
  name                     = var.name
  # Primary CIDR block for the subnetwork
  ip_cidr_range            = var.ip_cidr_range
  # GCP region for the subnetwork
  region                   = var.region
  # Parent network; typically module.vpc.self_link
  network                  = var.network
  # Project where the subnetwork will be created
  project                  = var.project
  # Allow VMs in the subnet to reach Google APIs without external IPs
  private_ip_google_access = var.private_ip_google_access

  # Secondary IP ranges: used by GKE IP-aliases for pods and services.
  # This block is generated dynamically from var.secondary_ip_ranges,
  # which should be a list of objects { range_name, ip_cidr_range }.
  dynamic "secondary_ip_range" {
    for_each = var.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}
