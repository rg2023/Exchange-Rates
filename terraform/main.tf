resource "google_service_account" "cloudbuild_sa" {
  account_id   = "cloud-build-sa"
  display_name = "Cloud Build SA"
}
module "cloud_run_frontend" {
  source = "./modules/cloud_run"
  create_artifact_registry= true
  name   = "cloud-run-frontend"
  project_id = var.project_id  
  region = var.region
  service_account_id = "cloud-run-frontend-executor"
  service_account_display_name = "SA for running Cloud Run Frontend"
  invokers = [
    "user:rachelge-aaaa@sandboxgcp.cloud"
  ]
}

module "cloud_run_backend" {
  source = "./modules/cloud_run"
  create_artifact_registry =false
  name   = "cloud-run-backend"
  project_id = var.project_id
  region = var.region
  port = 8000
  service_account_id = "cloud-run-backend-executor"
  service_account_display_name = "SA for running Cloud Run Backend"
  invokers = [
    "serviceAccount:${module.cloud_run_frontend.service_account_email}"
  ]
}
module "cloudbuild_trigger_frontend" {
  source       = "./modules/cloud_build"
  project_id   = var.project_id
  trigger_name = "frontend-trigger"
  cloudbuild_sa_email = google_service_account.cloudbuild_sa.email
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
  cloudbuild_sa_email = google_service_account.cloudbuild_sa.email
  trigger_path = "server/cloudbuild-server.yaml"
  github_owner = "rg2023"
  github_repo  = "Exchange-Rates"
  trigger_branch = "^master$"
  included_files = ["server/**"]

 cloud_run_service_accounts = {
    backend  = module.cloud_run_backend.service_account_email
} 
 }