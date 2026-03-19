/*
GKE cluster resource: creates a Google Kubernetes Engine cluster.

Key points:
 - `remove_default_node_pool = true` and a separate `google_container_node_pool`
   resource are used to allow fine-grained node pool configuration and autoscaling.
 - `ip_allocation_policy` references secondary ranges created on the subnet
   to enable IP aliasing for pods and services.
 - `workload_identity_config` enables Workload Identity when requested.
 - `private_cluster_config` toggles private node behavior (no external IPs).
 - `master_authorized_networks_config` allows restricting control plane access.
*/
resource "google_container_cluster" "this" {
  # Cluster name and location
  name     = var.name
  project  = var.project
  location = var.region
  deletion_protection = var.deletion_protection

  # Networking: VPC and subnetwork references
  network    = var.network
  subnetwork = var.subnetwork

  # We remove the provider-created default node pool and manage pools explicitly
  initial_node_count       = var.node_pool_initial_node_count
  remove_default_node_pool = true

  # IP aliasing: point to subnetwork secondary ranges for pods and services
  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name != "" ? var.cluster_secondary_range_name : null
    services_secondary_range_name = var.services_secondary_range_name != "" ? var.services_secondary_range_name : null
  }

  # Workload Identity: configure the workload pool for KSA -> GSA bindings
  workload_identity_config {
    workload_pool = var.enable_workload_identity ? "${var.project}.svc.id.goog" : null
  }

  # Private cluster options: control whether nodes have external IPs and
  # whether the control plane endpoint is private.
  private_cluster_config {
    enable_private_nodes    = var.enable_private_cluster
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr
  }

  # Master authorized networks: restrict API server access to specific CIDRs.
  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks
    content {
      # Each `cidr_blocks` block expects a `cidr_block` and optional display_name
      cidr_blocks {
        cidr_block   = master_authorized_networks_config.value.cidr_block
        display_name = master_authorized_networks_config.value.display_name
      }
    }
  }
}

/*
Primary node pool resource: creates a managed node pool for the cluster.

Node pool specifics:
 - `node_config.service_account` is set to the node service account created by
   the module (or supplied by the caller) so nodes run under a dedicated SA.
 - Autoscaling block controls min/max nodes for the pool.
 - Management enables auto-repair and auto-upgrade for nodes.
*/
resource "google_container_node_pool" "primary" {
  name     = "${var.name}-pool"
  project  = var.project
  location = var.region
  cluster  = google_container_cluster.this.name

  # Set initial node count for the pool (Terraform-managed count)
  node_count = var.node_pool_initial_node_count

  node_config {
    # Instance machine type for nodes
    machine_type   = var.node_machine_type
    # Service account assigned to VM instances in this node pool
    service_account = local.node_service_account
  }

  # Autoscaling settings for the node pool
  autoscaling {
    min_node_count = var.node_pool_min_count
    max_node_count = var.node_pool_max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Create a node service account if none supplied
/*
Optional node service account: if the caller does not provide a
`node_service_account_email`, this module creates one and uses it for
the VM nodes. Creating a dedicated SA makes it easier to follow
least-privilege principles and to bind roles later.
*/
resource "google_service_account" "node_sa" {
  count      = var.node_service_account_email == "" ? 1 : 0
  account_id = "${var.name}-node-sa"
  project    = var.project
}

# Bind the k8s service account to the GCP service account for Workload Identity
/*
If Workload Identity is enabled and a Kubernetes service account is provided
via `workload_identity_k8s_sa` (format: namespace/name), create an IAM
binding that allows that KSA to impersonate the GCP service account.
*/
resource "google_service_account_iam_member" "workload_identity" {
  count = var.enable_workload_identity && var.workload_identity_k8s_sa != "" ? 1 : 0

  service_account_id = length(google_service_account.node_sa) > 0 ? google_service_account.node_sa[0].email : var.node_service_account_email
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[${var.workload_identity_k8s_sa}]"
}

/*
Local values to simplify references. `node_service_account` resolves to the
provided node SA email or the email of the created service account.
*/
locals {
  node_service_account = var.node_service_account_email != "" ? var.node_service_account_email : (length(google_service_account.node_sa) > 0 ? google_service_account.node_sa[0].email : null)
}

resource "google_project_iam_member" "node_sa_roles" {
  for_each = toset(var.node_service_account_roles)

  project = var.project
  role    = each.key
  member  = "serviceAccount:${local.node_service_account}"
}
