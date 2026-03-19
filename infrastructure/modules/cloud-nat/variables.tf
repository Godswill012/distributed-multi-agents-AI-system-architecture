/*
Cloud NAT module inputs.
These control NAT allocation and which subnetwork ranges are NATed.
*/

variable "name" {
	type = string
}

variable "project" {
	type = string
}

variable "router" {
	description = "The name of the cloud router to attach the NAT to"
	type        = string
}

variable "region" {
	type = string
}

variable "nat_ip_allocate_option" {
	description = "AUTO_ONLY (create ephemeral nat IPs) or MANUAL_ONLY"
	type        = string
	default     = "AUTO_ONLY"
}

variable "source_subnetwork_ip_ranges_to_nat" {
	description = "Which subnetwork IP ranges will be NATed (eg ALL_SUBNETWORKS_ALL_IP_RANGES)"
	type        = string
	default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "min_ports_per_vm" {
	description = "Minimum number of NAT ports allocated per VM (tunes concurrency)"
	type        = number
	default     = 64
}
