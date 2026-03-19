/*
Cloud Router provides BGP routing services used by Cloud NAT and hybrid
connectivity. Creating a router is required before adding NATs.
*/
resource "google_compute_router" "this" {
  # Router name
  name    = var.name
  # Project where the router lives
  project = var.project
  # Network to attach the router to (module.vpc.self_link)
  network = var.network
  # Region for the router
  region  = var.region

  # Basic BGP config; ASN used for peering if needed
  bgp {
    asn = var.bgp_asn
  }
}
