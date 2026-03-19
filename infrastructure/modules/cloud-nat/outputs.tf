/*
Cloud NAT outputs: expose the NAT name for reference by other resources
or for debugging/monitoring purposes.
*/
output "name" { value = google_compute_router_nat.this.name }
