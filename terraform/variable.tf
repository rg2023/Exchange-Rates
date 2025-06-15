variable "region" {
  type    = string
  default = "me-west1"
}
variable "project_id" {
  type    = string
}
variable "sa_email_to_impersonate" {
  type = string 
}
variable "image_url" {
  description = "Docker image URL for Cloud Run"
  type        = string
}
variable "required_apis" {
  type = list(string)
  default = [
    "iam.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}
data "google_project" "current" {
  project_id = var.project_id
}