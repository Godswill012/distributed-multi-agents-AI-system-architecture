output "backend_bucket_name" {
  description = "Name of the Terraform backend bucket"
  value       = google_storage_bucket.terraform_state.name
}

output "backend_bucket_url" {
  description = "URL of the Terraform backend bucket"
  value       = google_storage_bucket.terraform_state.url
}