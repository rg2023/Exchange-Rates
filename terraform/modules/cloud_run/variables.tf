variable "region" {
  type = string
}
variable "project_id" {
  type = string
}
variable "image" {
  type = string
  default = "gcr.io/cloudrun/hello"
}
variable "port" {
  type    = number
  default = 80
}
variable "service_account_id" {
  type = string
}
variable "service_account_display_name" {
  type = string
}
variable "invokers" {
  type    = list(string)
  default = []
}
variable "name" {
  type = string
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
variable "create_artifact_registry" {
  type = bool
  default = false
}