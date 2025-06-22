variable "trigger_name" {
  type        = string 
}
variable "included_files" {
  type        = list(string)
}
variable "project_id" {
  type = string
}
variable "github_owner" {
  type = string
}
variable "github_repo" {
  type = string
}
variable "trigger_branch" {
  type    = string
}
variable "trigger_path" {
  type    = string
}
variable "cloud_run_service_accounts" {
  type = map(string)
}
variable "service_account_id" {
  type = string 
}
variable "cloudbuild_sa_email" {
  type = string
}