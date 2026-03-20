variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "backend_bucket_name" {
  description = "Name of the GCS bucket used for Terraform remote state (must start with 'nvit-buckets')"
  type        = string

  validation {
    condition     = can(regex("^nvit-buckets", var.backend_bucket_name))
    error_message = "Bucket name must start with 'nvit-buckets'."
  }
}