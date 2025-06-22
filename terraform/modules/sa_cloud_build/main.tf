resource "google_service_account" "cloudbuild_sa" {
  account_id   = "cloud-build-sa"
  display_name = "Cloud Build SA"
}

resource "google_project_iam_member" "cloudbuild_sa_builds_editor" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

resource "google_project_iam_member" "cloudbuild_sa_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

resource "google_project_iam_member" "cloudbuild_sa_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}
resource "google_project_iam_member" "cloud_build_logs_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

# אלו משאבים שדורשים service account של cloud run - יש להעביר בכניסה למודול את המיילים שלהם (כדי ליצור את המשאבים האלה, ניצור משתנים)
resource "google_service_account_iam_member" "cloudbuild_act_as_cloudrun" {
  for_each = var.cloud_run_service_accounts
  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value}"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}