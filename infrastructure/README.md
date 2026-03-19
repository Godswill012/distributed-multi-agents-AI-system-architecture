# Infrastructure README

Quick overview
- Location: `infrastructure/` contains Terraform modules and environment compositions.
- Use `infrastructure/environments/dev` as an example environment.

Prerequisites
- GCP project and billing enabled.
- Enable APIs: Compute Engine, Kubernetes Engine, Cloud Resource Manager, Cloud NAT, IAM, and Cloud Storage (for remote state).
- Install Terraform (recommended >= 1.4) and `gcloud` for authentication.

Authentication
- Use Application Default Credentials or set `GOOGLE_CREDENTIALS` with a service account JSON that has appropriate Terraform permissions.

Common commands
```powershell
cd infrastructure/environments/dev
# init (use backend.tf if enabled)
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Remote state
- Copy `backend.tf.example` → `backend.tf`, set `bucket` and run `terraform init` to enable GCS backend.

Post-deploy Kubernetes
- After cluster creation, enable the Kubernetes provider using the cluster endpoint and credentials, then apply resources. Example provider and example k8s resources live under `infrastructure/environments/dev/k8s/*.tf.example`.

Notes
- The modules are intentionally minimal and designed for extension. Review node service account IAM roles, NAT configuration, and master authorized networks before production deployment.
