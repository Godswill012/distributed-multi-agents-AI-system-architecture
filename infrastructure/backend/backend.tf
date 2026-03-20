# Terraform GCS backend template. Replace values or pass via -backend-config when running `terraform init`.

terraform {
  backend "gcs" {
    # Set the following values via a secure mechanism (CI secrets / -backend-config):
    # bucket = "my-terraform-state-bucket"
    # prefix = "terraform/state"
    # credentials = "path/to/service-account-key.json"  # optional for local runs

    # Example (for simple local testing only):
    # bucket = "my-terraform-state-bucket"
    # prefix = "envs/prod/terraform.tfstate"
  }
}
