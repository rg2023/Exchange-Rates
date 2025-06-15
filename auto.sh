# !/bin/bash

# Authenticate and move to terraform directory
gcloud auth application-default login
cd terraform

# Init and create Artifact Registry if not exists
terraform init
terraform apply -target=google_artifact_registry_repository.artifact -auto-approve

# Build and push backend image
BACKEND_IMAGE="me-west1-docker.pkg.dev/sandbox-lz-rachelge/repo/server:latest"
docker build -t $BACKEND_IMAGE ../server
docker push $BACKEND_IMAGE

# Deploy backend
terraform apply \
  -var="image_url=$BACKEND_IMAGE" \
  -target=google_service_account.sa_cloud_run_server \
  -target=google_cloud_run_service.cloud_run_server \
  -target=google_project_iam_member.sa_server \
  -auto-approve

# Wait for backend to be ready and get URL
BACKEND_URL=$(gcloud run services describe cloud-run-server --platform=managed --project=sandbox-lz-rachelge --region=me-west1 --format="value(status.url)")


# -build-arg VITE_BACKEND_URL=$BACKEND_URL
# Build and push frontend image
FRONTEND_IMAGE="me-west1-docker.pkg.dev/sandbox-lz-rachelge/repo/frontend:latest"
docker build -t $FRONTEND_IMAGE ../client/my-app
docker push $FRONTEND_IMAGE

# Deploy frontend
terraform apply \
  -var="image_url=$FRONTEND_IMAGE" \
  -auto-approve
