resource "google_cloudbuild_trigger" "trigger" {
  name         = var.trigger_name
  filename     = var.trigger_path
  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = var.trigger_branch
    }
  }
  included_files  = var.included_files
  service_account = "projects/${var.project_id}/serviceAccounts/${var.service_account_email}"
}

