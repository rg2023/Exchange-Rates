output "service_account_email" {
  description = "The email of the service account created for this Cloud Run service"
  value       = google_service_account.this.email
}
