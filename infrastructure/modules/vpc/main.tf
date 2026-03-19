/*
This module creates a VPC network.
The `google_compute_network` resource defines a custom-mode VPC where
we set `auto_create_subnetworks = false` so subnetworks are created
explicitly (by the `subnet` module). `routing_mode` controls global
vs regional routing.
*/
resource "google_compute_network" "this" {
  # Human-friendly name for the VPC
  name                    = var.name
  # GCP project that will own the VPC
  project                 = var.project
  # Prevent automatic subnet creation; we'll create subnets explicitly
  auto_create_subnetworks = false
  # Optional description for the network
  description             = var.description
  # Routing mode (REGIONAL or GLOBAL) affects how routes are propagated
  routing_mode            = var.routing_mode
}
