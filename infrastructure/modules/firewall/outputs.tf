/*
Firewall module outputs: expose the created firewall name for reference
in other modules or environments.
*/
output "name" { value = google_compute_firewall.this.name }
