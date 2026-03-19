variable "project" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "subnet_ip_cidr" {
  type = string
}

variable "subnet_secondary_ranges" {
  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))
  default = []
}

variable "firewall_name" {
  type = string
}

variable "firewall_allow" {
  type = list(object({
    protocol = string
    ports    = list(string)
  }))
  default = []
}

variable "router_name" {
  type = string
}

variable "nat_name" {
  type = string
}

variable "gke_name" {
  type = string
}

variable "gke_cluster_secondary_range_name" {
  type = string
}

variable "gke_services_secondary_range_name" {
  type = string
}

variable "node_machine_type" {
  type = string
}

variable "node_pool_initial_node_count" {
  type = number
}

variable "node_pool_min_count" {
  type = number
}

variable "node_pool_max_count" {
  type = number
}

variable "enable_workload_identity" {
  type    = bool
  default = true
}

variable "enable_private_cluster" {
  type    = bool
  default = true
}

variable "enable_private_endpoint" {
  type    = bool
  default = false
}

variable "master_ipv4_cidr" {
  type = string
}

variable "workload_identity_k8s_sa" {
  type    = string
  default = ""
}

variable "node_service_account_roles" {
  type    = list(string)
  default = []
}

variable "private_ip_google_access" {
  type = bool
}

variable "deletion_protection" {
  type    = bool
  default = false
}