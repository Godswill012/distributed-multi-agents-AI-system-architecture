variable "name" { type = string }
variable "project" { type = string }
variable "region" { type = string }
variable "network" { type = string }
variable "subnetwork" { type = string }

variable "cluster_secondary_range_name" {
	type    = string
	default = ""
}

variable "services_secondary_range_name" {
	type    = string
	default = ""
}

# Node pool configuration
variable "node_machine_type" {
	type    = string
	default = "e2-medium"
}

variable "node_pool_initial_node_count" {
	type    = number
	default = 1
}

variable "node_pool_min_count" {
	type    = number
	default = 1
}

variable "node_pool_max_count" {
	type    = number
	default = 3
}

variable "node_service_account_email" {
	description = "Optional service account email for node pool service account"
	type        = string
	default     = ""
}

# Workload Identity
variable "enable_workload_identity" {
	type    = bool
	default = false
}

# Private cluster options
variable "enable_private_cluster" {
	type    = bool
	default = false
}

variable "enable_private_endpoint" {
	type    = bool
	default = false
}

variable "master_ipv4_cidr" {
	type    = string
	default = "172.16.0.0/28"
}

/*
Workload Identity: the Kubernetes service account in the format "namespace/name".
If supplied along with enable_workload_identity = true, the module will
create the IAM binding allowing the KSA to impersonate the GSA.
*/
variable "workload_identity_k8s_sa" {
	type    = string
	default = ""
}

/*
Master authorized networks: a list of objects to restrict API server access,
each object should be { cidr_block = "x.x.x.x/x", display_name = "..." }
*/
variable "master_authorized_networks" {
	type = list(object({ cidr_block = string, display_name = string }))
	default = []
}

/*
List of IAM roles to grant to the node service account. Typical minimal roles
include logging, monitoring, and container node service account role; adjust
to your least-privilege policy.
*/
variable "node_service_account_roles" {
	description = "List of IAM roles (eg. roles/compute.instanceAdmin.v1) to grant the node service account"
	type        = list(string)
	default     = []
}

variable "deletion_protection" {
    type    = bool
    default = false
}
