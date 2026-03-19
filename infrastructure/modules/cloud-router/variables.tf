/*
Variables for the Cloud Router module.
The router is regional and attaches to a VPC network.
*/

variable "name" {
  type = string
}

variable "project" {
  type = string
}

variable "network" {
  type = string
}

variable "region" {
  type = string
}

variable "bgp_asn" {
  description = "BGP ASN used by the router (default chosen arbitrarily)"
  type        = number
  default     = 64514
}
