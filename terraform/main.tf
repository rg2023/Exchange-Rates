module "service_accounts" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "4.5.4"
  project_id = var.project_id
  names = ["cloud-run-backend-sa"]
}
resource "google_project_iam_member" "service_account_roles" {
  for_each = toset([
    "roles/storage.objectAdmin",
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor",
    "roles/aiplatform.user"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${module.service_accounts.email}"
}
module "cloud_run_backend" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloud-run?ref=master"
  project_id = var.project_id
  region     = var.region
  name       = "cloud-run-backend"
  containers = {
    backend = {
      image = "gcr.io/cloudrun/hello"
      port = 8080
    }
  }
   iam = {
  "roles/run.invoker" = [
    "user:rachelge-aaaa@sandboxgcp.cloud",
    "serviceAccount:${module.service_accounts.email}",
  ]
}
 service_account = module.service_accounts.email
}

module "artifact-registry" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "0.3.0"
  project_id    = var.project_id
  location      = var.region
  format        = "DOCKER"
  repository_id = "repo"
}
resource "random_password" "db_password" {
  length  = 16
  special = true
}
module "secret-manager" {
  source  = "GoogleCloudPlatform/secret-manager/google"
  version = "0.8.0"
  project_id = var.project_id
  secrets = [
    {
      name                  = "${var.db_instance}-password"
      automatic_replication = true
      secret_data          = random_password.db_password.result
    },
      {
      name                  = "${var.db_instance}-user"
      automatic_replication = true
      secret_data          = "rachel"
    },
    {
      name                  = "${var.db_instance}-name"
      automatic_replication = true
      secret_data          = var.db_name
    },
    {
      name                  = "${var.db_instance}-host"
      automatic_replication = true
      secret_data          = "${var.project_id}:${var.region}:${var.db_instance}"
    }
  ]
}
resource "google_sql_user" "default_user" {
  name     = "rachel"
  instance = module.sql-db.instance_name
  password = random_password.db_password.result
}
resource "google_sql_database" "my_database" {
  name     = var.db_name
  instance = module.sql-db.instance_name
  charset  = "utf8"
  collation = "utf8_general_ci"
}
module "sql-db" {
  source  = "terraform-google-modules/sql-db/google//modules/mysql"
  version = "25.2.2"
  name                 = var.db_instance
  database_version     = "MYSQL_5_6"
  project_id           = var.project_id
  zone                 = "me-west1-a"
  region               = var.region
  tier                 = "db-n1-standard-1"
  root_password = random_password.db_password.result
  deletion_protection = false
  backup_configuration = {
    enabled    = true
    start_time = "03:00"
  }
  ip_configuration = {
    ipv4_enabled    = true
    private_network = null
    require_ssl     = false
    authorized_networks = [
      {
        name  = "my-cloudshell"
        value = "34.0.0.0/8" 
      }
    ]
  }
}
module "bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 11.0"
  name       = "bucket_${var.project_id}"
  project_id = var.project_id
  location   = var.region
  iam_members = [{
    role   = "roles/storage.objectViewer"
    member = "user:rachelge-aaaa@sandboxgcp.cloud"
  }]
  
  force_destroy = true
}
module "create_sa_cloudbuild" {
  source               = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account"
  project_id           = var.project_id
  name                 = "sa-cloudbuild"
  service_account_create = true
  description          = "Service Account for Cloud Build"
  display_name         = "Cloud Build Service Account"
  iam_project_roles = {
    "${var.project_id}" = [
      "roles/cloudbuild.builds.editor",
      "roles/run.admin",
      "roles/artifactregistry.writer",
      "roles/logging.logWriter",
    ]
  }
  iam_sa_roles = {
    # "projects/${var.project_id}/serviceAccounts/${module.cloud_run_frontend.service_account_email}" = [
    #   "roles/iam.serviceAccountUser"
    # ],
    "projects/${var.project_id}/serviceAccounts/${module.cloud_run_backend.service_account_email}" = [
      "roles/iam.serviceAccountUser"
    ]
  }
}
module "cloudbuild_trigger_backend" {
  source       = "./module/cloud_build"
  project_id   = var.project_id
  trigger_name = "backend-trigger"
  trigger_path = "server/cloud-build-server.yaml"
  github_owner = "rg2023"
  github_repo  = "Project_"
  trigger_branch = "^master$"
  included_files = ["server/**"]
  service_account_email = module.create_sa_cloudbuild.email
 }


# module "cloud_run_frontend" {
#   source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloud-run?ref=master"
#   project_id = var.project_id
#   region     = var.region
#   name       = "cloud-run-frontend"
#   containers = {
#     frontend = {
#       image = "gcr.io/cloudrun/hello"
#         port  = 80
#     }
#   }
#   iam = {
#     "roles/run.invoker" = ["user:rachelge-aaaa@sandboxgcp.cloud"]
#   }
#   service_account_create = true
# }
# module "cloud_run_backend" {
#   source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloud-run?ref=master"
#   project_id = var.project_id
#   region     = var.region
#   name       = "cloud-run-backend"
#   containers = {
#     backend = {
#       image = "gcr.io/cloudrun/hello"
#       port  = 8000
#     }
#   }
#  iam = {
#   "roles/run.invoker" = [
#     "user:rachelge-aaaa@sandboxgcp.cloud",
#     "serviceAccount:sa-cloudbuild@sandbox-lz-rachelge.iam.gserviceaccount.com"
#   ]
# }
#   service_account_create = true
# }
# module "docker_artifact_registry" {
#   source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/artifact-registry?ref=master"
#   project_id = var.project_id
#   location   = var.region
#   name       = "repo"
#   format     = { docker = { standard = {} } }
#   iam = {
#     "roles/artifactregistry.admin" = ["user:rachelge-aaaa@sandboxgcp.cloud"]
#     "roles/artifactregistry.reader" = ["serviceAccount:${module.cloud_run_frontend.service_account_email}"]
#     "roles/artifactregistry.reader" = ["serviceAccount:${module.cloud_run_backend.service_account_email}"]
#   }
# }
# module "create_sa_cloudbuild" {
#   source               = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account"
#   project_id           = var.project_id
#   name                 = "sa-cloudbuild"
#   service_account_create = true
#   description          = "Service Account for Cloud Build"
#   display_name         = "Cloud Build Service Account"

#   # הרשאות פרויקט שה-SA יקבל
#   iam_project_roles = {
#     "${var.project_id}" = [
#       "roles/cloudbuild.builds.editor",
#       "roles/run.admin",
#       "roles/artifactregistry.writer",
#       "roles/logging.logWriter",
#     ]
#   }

#   # הרשאות "ActAs" (Service Account roles granted to this SA on other SAs)
#   iam_sa_roles = {
#     "projects/${var.project_id}/serviceAccounts/${module.cloud_run_frontend.service_account_email}" = [
#       "roles/iam.serviceAccountUser"
#     ],
#     "projects/${var.project_id}/serviceAccounts/${module.cloud_run_backend.service_account_email}" = [
#       "roles/iam.serviceAccountUser"
#     ]
#   }
# }
# module "cloudbuild_trigger_frontend" {
#   source       = "./modules/cloud_build"
#   project_id   = var.project_id
#   service_account_email = module.create_sa_cloudbuild.email
#   trigger_name = "frontend-trigger"
#   trigger_path = "client/my-app/cloudbuild-front.yaml"
#   github_owner = "rg2023"
#   github_repo  = "Exchange-Rates"
#   trigger_branch = "^master$"
#   included_files = ["client/**"]
# }


# module "cloudbuild_trigger_backend" {
#   source       = "./modules/cloud_build"
#   project_id   = var.project_id
#   trigger_name = "backend-trigger"
#   trigger_path = "server/cloudbuild-server.yaml"
#   github_owner = "rg2023"
#   github_repo  = "Exchange-Rates"
#   trigger_branch = "^master$"
#   included_files = ["server/**"]
#   service_account_email = module.create_sa_cloudbuild.email
#  }