/*
Subnetwork module inputs. These variables control the subnetwork
and any optional secondary ranges used for things like GKE IP aliasing.
*/

# Subnetwork name
variable "name" {
	type = string
}

# Project where the subnetwork is created
variable "project" {
	type = string
}

# Region for the subnet
variable "region" {
	type = string
}

# Parent VPC network (pass module.vpc.self_link)
variable "network" {
	type = string
}

# Primary CIDR block for this subnetwork (eg. 10.10.0.0/20)
variable "ip_cidr_range" {
	type = string
}

# If true, VMs in this subnet can use private IPs to reach Google APIs
variable "private_ip_google_access" {
	type    = bool
	default = true
}

# Secondary IP ranges: list of { range_name, ip_cidr_range } for
# GKE pods/services secondary ranges. These are created on the subnetwork
# and referenced by the GKE `ip_allocation_policy`.
variable "secondary_ip_ranges" {
	description = "List of secondary ranges for the subnetwork (range_name + ip_cidr_range) used by GKE IP aliases"
	type        = list(object({ range_name = string, ip_cidr_range = string }))
	default     = []
}
