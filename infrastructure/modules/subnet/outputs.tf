/*
Subnetwork exported values. Use these when wiring other modules (for example,
the GKE module needs the `self_link` for the `subnetwork` argument).
*/
output "name" { value = google_compute_subnetwork.this.name }
output "self_link" { value = google_compute_subnetwork.this.self_link }
