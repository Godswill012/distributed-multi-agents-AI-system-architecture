/*
Module inputs for the VPC module.
Each variable controls attributes of the `google_compute_network`.
*/

# Name of the VPC network to create
variable "name" {
  type = string
}

# GCP project id where the VPC will be created
variable "project" {
  type = string
}

# Optional description stored on the network resource
variable "description" {
  type    = string
  default = ""
}

# Routing mode: REGIONAL (default) or GLOBAL
variable "routing_mode" {
  type    = string
  default = "REGIONAL"
}
