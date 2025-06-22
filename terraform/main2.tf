module "cloud_run_frontend" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloud-run?ref=master"
  project_id = var.project_id
  region     = var.region
  name       = "cloud-run-frontend"
  containers = {
    frontend = {
      image = "gcr.io/cloudrun/hello"
        port  = 80
    }
  }
  iam = {
    "roles/run.invoker" = ["user:rachelge-aaaa@sandboxgcp.cloud"]
  }
  service_account_create = true
}
module "cloud_run_backend" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloud-run?ref=master"
  project_id = var.project_id
  region     = var.region
  name       = "cloud-run-backend"
  containers = {
    backend = {
      image = "gcr.io/cloudrun/hello"
      port  = 8000
    }
  }
  iam = {
    "roles/run.invoker" = ["serviceAccount:${module.cloud_run_frontend.service_account_email}"]
  }
  service_account_create = true
}
module "docker_artifact_registry" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/artifact-registry?ref=master"
  project_id = var.project_id
  location   = var.region
  name       = "repo"
  format     = { docker = { standard = {} } }
  iam = {
    "roles/artifactregistry.admin" = ["user:rachelge-aaaa@sandboxgcp.cloud"]
    "roles/artifactregistry.reader" = ["serviceAccount:${module.cloud_run_frontend.service_account_email}"]
    "roles/artifactregistry.reader" = ["serviceAccount:${module.cloud_run_backend.service_account_email}"]
  }
}
resource "google_service_account" "cloudbuild_sa" {
  account_id   = "cloud-build-sa"
  display_name = "Cloud Build SA"
}
module "cloudbuild_trigger_frontend" {
  source       = "./modules/cloud_build"
  project_id   = var.project_id
  service_account_email = google_service_account.cloudbuild_sa.email
  trigger_name = "frontend-trigger"
  trigger_path = "client/my-app/cloudbuild-front.yaml"
  github_owner = "rg2023"
  github_repo  = "Exchange-Rates"
  trigger_branch = "^master$"
  included_files = ["client/**"]

cloud_run_service_accounts = {
  frontend = module.cloud_run_frontend.service_account_email
}

}


module "cloudbuild_trigger_backend" {
  source       = "./modules/cloud_build"
  project_id   = var.project_id
  trigger_name = "backend-trigger"
  service_account_email = google_service_account.cloudbuild_sa.email
  trigger_path = "server/cloudbuild-server.yaml"
  github_owner = "rg2023"
  github_repo  = "Exchange-Rates"
  trigger_branch = "^master$"
  included_files = ["server/**"]

 cloud_run_service_accounts = {
    backend  = module.cloud_run_backend.service_account_email
}
 }