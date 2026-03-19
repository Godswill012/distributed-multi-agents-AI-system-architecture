/*
Cloud Router outputs: expose router name for reference by NAT and other modules.
*/
output "name" { value = google_compute_router.this.name }
