resource "google_project_service" "enabled_apis" {
  for_each = toset(var.required_apis)

  project = var.project_id
  service = each.key

  disable_on_destroy = false
}
resource "google_artifact_registry_repository" "artifact" {
  location      = var.region
  repository_id = "repo"
  format        = "DOCKER"
  depends_on = [google_project_service.enabled_apis["artifactregistry.googleapis.com"]]
}


# resource "google_cloud_run_service" "cloud_run_server" {
#   name     = "cloud-run-server"
#   location = var.region
#   template {
#     spec {
#       service_account_name = google_service_account.sa_cloud_run_server.email
#       containers {
#         image = "me-west1-docker.pkg.dev/sandbox-lz-rachelge/repo/server:latest"
#          ports {
#           container_port = 8000
#         }
        
#       }
#     }
#   }

#   traffic {
#     percent         = 100
#     latest_revision = true
#   }
# }
# resource "google_service_account" "sa_cloud_run_server" {
#   account_id   = "cloud-run-executor-server"
#   display_name = "SA for running Cloud Run"
# }
# resource "google_project_iam_member" "sa_server" {
#   role   = "roles/artifactregistry.reader" 
#   member = "serviceAccount:${google_service_account.sa_cloud_run_server.email}"
#   project = var.project_id
# }




# resource "google_service_account" "sa_cloud_run_client" {
#   account_id   = "cloud-run-executor-client"
#   display_name = "SA for running Cloud Run"
# }
# resource "google_cloud_run_service_iam_member" "sa_frontend" {
#   location = var.region
#   service  = google_cloud_run_service.cloud_run_frontend.name
#   role     = "roles/run.invoker"
#   member   = "user:rachelge-aaaa@sandboxgcp.cloud"
# }

# # גישה ל־frontend להריץ את backend
# resource "google_cloud_run_service_iam_member" "backend_allow_frontend" {
#   location = google_cloud_run_service.cloud_run_server.location
#   service  = google_cloud_run_service.cloud_run_server.name
#   role     = "roles/run.invoker"
#   # זה הסרוויס אקאונט של הפרונט
#    member = "serviceAccount:${google_service_account.sa_cloud_run_client.email}"
# }
# resource "google_cloud_run_service" "cloud_run_frontend" {
#   name     = "cloud-run-frontend"
#   location = var.region
#   template {
#     spec {
#       service_account_name = google_service_account.sa_cloud_run_client.email
#       containers {
#         image = "me-west1-docker.pkg.dev/sandbox-lz-rachelge/repo/frontend:latest"
#         ports {
#           container_port = 80
#         }
#         env {
#           name  = "VITE_BACKEND_URL" # השם שתבחרי למשתנה הסביבה בקוד הפרונטאנד שלך
#           value = google_cloud_run_service.cloud_run_server.status[0].url # הערך הוא ה-URL מהבאקאנד!
#         }
#       }
#     }
#   }

#   traffic {
#     percent         = 100
#     latest_revision = true
#   }
# }

resource "google_secret_manager_secret_iam_member" "cloudbuild_can_access_versions" {
  secret_id = "github"
  role      = "roles/secretmanager.admin"
  member    = "serviceAccount:service-452333776264@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}
resource "google_service_account" "cloudbuild_sa" {
  account_id   = "cloud-build-sa"
  display_name = "Cloud Build SA"
  project      = var.project_id
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
resource "google_project_iam_member" "cloudbuild_sa_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}
resource "google_cloudbuildv2_repository" "my_repository" {
  name              = "Exchange-Rates"  # השם של הריפו בגיטהאב
  parent_connection = "projects/sandbox-lz-rachelge/locations/me-west1/connections/github"
  remote_uri        = "https://github.com/rg2023/Exchange-Rates.git"
}
resource "google_cloudbuild_trigger" "github_trigger" {
  name = "exchange-rates-trigger"
  filename = "cloudbuild.yaml"  # שם הקובץ של ה־Cloud Build Trigger
  github {
    owner = "rg2023"
    name  = "Exchange-Rates"

    push {
      branch = "^master$"
    }
  }

  service_account = "projects/${var.project_id}/serviceAccounts/${google_service_account.cloudbuild_sa.email}"
}


#==============================================================================לואוד באלאנסר בשביל הקלאוד רן
# resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
#   name                  = "cloud-run-neg"
#   region                = var.region
#   network_endpoint_type = "SERVERLESS"
#   cloud_run {
#     service = google_cloud_run_service.cloud_run_server.name
#   }
# }

# resource "google_compute_backend_service" "run_backend" {
#   name                  = "cloudrun-backend"
#   load_balancing_scheme = "EXTERNAL_MANAGED"
#   protocol              = "HTTP"
#   backend {
#     group = google_compute_region_network_endpoint_group.cloud_run_neg.id
#   }
#   enable_cdn = true

#   log_config {
#     enable = true
#   }
# }

# resource "google_compute_url_map" "default" {
#   name            = "run-url-map"
#   default_service = google_compute_backend_service.run_backend.id
# }

# resource "google_compute_target_http_proxy" "default" {
#   name    = "http-proxy"
#   url_map = google_compute_url_map.default.id
# }

# resource "google_compute_global_address" "default" {
#   name = "lb-ip"
# }

# resource "google_compute_global_forwarding_rule" "default" {
#   name       = "http-rule"
#   ip_address = google_compute_global_address.default.address
#   port_range = "80"
#   target     = google_compute_target_http_proxy.default.id
# }


#......................................................................................................................... לואוד באלאנסר
# resource "google_compute_backend_service" "run_backend" {
#   name                            = "cloudrun-backend"
#   load_balancing_scheme           = "EXTERNAL_MANAGED"
#   protocol                        = "HTTP"
#   enable_cdn                      = true
#   backend {
#     group = data.google_cloud_run_service.my_service.status[0].url
#   }

#   log_config {
#     enable = true
#   }

#   custom_request_headers = [
#     "Host: ${data.google_cloud_run_service.my_service.status[0].url}"
#   }
# }

# # URL Map
# resource "google_compute_url_map" "default" {
#   name            = "run-url-map"
#   default_service = google_compute_backend_service.run_backend.id
# }

# # HTTP Proxy
# resource "google_compute_target_http_proxy" "default" {
#   name   = "http-proxy"
#   url_map = google_compute_url_map.default.id
# }

# # כתובת IP חיצונית
# resource "google_compute_global_address" "default" {
#   name = "lb-ip"
# }

# # Forwarding Rule
# resource "google_compute_global_forwarding_rule" "default" {
#   name       = "http-rule"
#   ip_address = google_compute_global_address.default.address
#   port_range = "80"
#   target     = google_compute_target_http_proxy.default.id
# }









#............................................................................................
#יצירת באקט בשביל הקלאוד בילד

# resource "google_storage_bucket" "source_code_bucket" {
#   name     = "${var.project_id}-source-code"
#   location = var.region
#   force_destroy = true
#   uniform_bucket_level_access = true
# }
#................................................................. יצירת קלאוד בילד
# resource "google_cloudbuild_build" "frontend_build" {
#   steps {
#     name = "gcr.io/cloud-builders/docker"
#     args = [
#       "build",
#       "-t",
#       "${google_artifact_registry_repository.docker_repo.repository_url}/frontend:manual",
#       "."
#     ]
#   }

#   images = [
#     "${google_artifact_registry_repository.docker_repo.repository_url}/frontend:manual"
#   ]

#   source {
#     storage_source {
#       bucket = google_storage_bucket.source_code_bucket.name
#       object = var.frontend_tarball_object  # שם הקובץ שהעלית, לדוג': "frontend.tar.gz"
#     }
#   }

#   timeout = "600s"
# }







































#-----------------------------------------------------------------------------------------------
# resource "google_service_account" "service_account" {
#   account_id   = "rg_sa_imersonate"            
#   display_name =  "RG Service Account"
# }

# resource "google_service_account_iam_member" "allow_impersonation" {
#   service_account_id = google_service_account.service_account.name
#   role               = "roles/iam.serviceAccountTokenCreator"
#   member             = "user:${var.user_to_impersonate}"
# }

