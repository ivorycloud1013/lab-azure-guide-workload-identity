output "service_account_id" {
  description = "GCP Service Account ID (email 의 @ 앞부분)"
  value       = google_service_account.this.account_id
}

output "service_account_email" {
  description = "GCP Service Account email"
  value       = google_service_account.this.email
}

output "service_account_unique_id" {
  description = "GCP Service Account unique ID (= OAuth2 Client ID = Google ID token 의 sub)"
  value       = google_service_account.this.unique_id
}
