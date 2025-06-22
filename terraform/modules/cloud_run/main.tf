resource "google_project_service" "enabled_apis" {
  for_each = toset(var.required_apis)

  project = var.project_id
  service = each.key

  disable_on_destroy = false
}
resource "google_artifact_registry_repository" "artifact" {
  count = var.create_artifact_registry ? 1 : 0
  location      = var.region
  repository_id = "repo"
  format        = "DOCKER"
  depends_on = [google_project_service.enabled_apis["artifactregistry.googleapis.com"]]
}

resource "google_service_account" "this" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}

resource "google_cloud_run_service" "this" {
  name     = var.name
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.this.email

      containers {
        image = var.image

        ports {
          container_port = var.port
        }

        # dynamic "env" {
        #   for_each = var.env_vars
        #   content {
        #     name  = env.key
        #     value = env.value
        #   }
        # }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "invokers" {
  for_each = toset(var.invokers)

  service  = google_cloud_run_service.this.name
  location = var.region
  role     = "roles/run.invoker"
  member   = each.value
}

resource "google_project_iam_member" "artifact_registry" {
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.this.email}"
  project = var.project_id
}
