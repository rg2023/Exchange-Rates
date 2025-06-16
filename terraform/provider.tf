provider "google" {
  project = "sandbox-lz-rachelge"
  region  = "us-central1"
  impersonate_service_account = var.sa_email_to_impersonate
}
terraform {
  backend "gcs" {
    bucket  = "gcs-terraform--state"
    prefix  = "terraform/state"
  }
  }
  

