# Foundry custom subdomain 은 전역 고유해야 하므로 suffix 를 붙인다
resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

locals {
  name_suffix = random_string.suffix.result
}

module "gcp" {
  source = "./modules/gcp"

  project_id         = var.gcp_project_id
  service_account_id = var.gcp_service_account_id
}

module "azure" {
  source = "./modules/azure"

  resource_group_name       = "rg-${var.name_prefix}"
  location                  = var.azure_location
  foundry_name              = "${var.name_prefix}-${local.name_suffix}"
  deployment_name           = var.deployment_name
  model_name                = var.model_name
  model_version             = var.model_version
  deployment_sku            = var.deployment_sku
  deployment_capacity       = var.deployment_capacity
  identity_name             = "id-${var.name_prefix}-gcp"
  federated_credential_name = "gcp-${var.gcp_service_account_id}"
  # GCP SA 의 unique_id 가 그대로 Federated Credential 의 subject 가 된다
  gcp_service_account_unique_id = module.gcp.service_account_unique_id
  allowed_ip_ranges             = var.allowed_ip_ranges
  tags                          = var.tags
}
