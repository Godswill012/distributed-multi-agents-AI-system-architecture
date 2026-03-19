/*
Outputs exported by the VPC module for other modules to reference.
`self_link` is useful when passing the network into other resources that
expect a network self link rather than a name.
*/
output "name" {
  value = google_compute_network.this.name
}

output "self_link" {
  value = google_compute_network.this.self_link
}
