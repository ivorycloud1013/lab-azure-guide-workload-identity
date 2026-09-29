# IAM Credentials API: impersonation(generateIdToken)에 필요
resource "google_project_service" "iamcredentials" {
  project            = var.project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}

# Azure Entra ID 가 신뢰할 GCP Service Account
resource "google_service_account" "this" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Azure Foundry workload identity (${var.service_account_id})"
  description  = "Google ID token 을 Entra ID 토큰으로 교환해 Azure Foundry 를 호출"
}
