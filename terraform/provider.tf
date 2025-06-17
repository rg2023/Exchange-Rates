provider "google" {
  project = var.project_id
  region  = var.region
  impersonate_service_account = var.sa_email_to_impersonate
}
terraform {
  backend "gcs" {
    bucket  = "gcs-terraform--state"
    prefix  = "terraform/state"
  }
  }
  

