terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
  # Remote backend configuration: replace `your-terraform-state-bucket` and
  # `infrastructure/dev` with your GCS bucket and prefix. If you prefer to
  # keep backend configuration out of version control, copy this block to a
  # separate `backend.tf` file and update values there before running
  # `terraform init`.
  /*backend "gcs" {
    bucket = "bucket=nvit-buckets-tf-state-487916"
    prefix = "infrastructure/dev"
  }
  */
}

provider "google" {
  project = var.project
  region  = var.region
}
