locals {
  # Google ID token 을 Entra ID 토큰으로 교환할 때 고정 값
  google_issuer           = "https://accounts.google.com"
  token_exchange_audience = "api://AzureADTokenExchange"
  is_network_restricted   = length(var.allowed_ip_ranges) > 0
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Foundry(AIServices) 리소스 - API key 를 막고 Entra ID 토큰만 허용
resource "azurerm_cognitive_account" "foundry" {
  name                  = var.foundry_name
  resource_group_name   = azurerm_resource_group.this.name
  location              = azurerm_resource_group.this.location
  kind                  = "AIServices"
  sku_name              = "S0"
  custom_subdomain_name = var.foundry_name
  local_auth_enabled    = false
  tags                  = var.tags

  network_acls {
    default_action = local.is_network_restricted ? "Deny" : "Allow"
    ip_rules       = var.allowed_ip_ranges
  }
}

resource "azurerm_cognitive_deployment" "image" {
  name                   = var.deployment_name
  cognitive_account_id   = azurerm_cognitive_account.foundry.id
  version_upgrade_option = "NoAutoUpgrade"

  model {
    format  = "OpenAI"
    name    = var.model_name
    version = var.model_version
  }

  sku {
    name     = var.deployment_sku
    capacity = var.deployment_capacity
  }
}

# GCP SA 가 "빙의"할 Azure 측 identity
resource "azurerm_user_assigned_identity" "gcp" {
  name                = var.identity_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags
}

# Google ID token(iss/sub/aud) 을 신뢰하도록 연결
resource "azurerm_federated_identity_credential" "gcp" {
  name                      = var.federated_credential_name
  user_assigned_identity_id = azurerm_user_assigned_identity.gcp.id
  issuer                    = local.google_issuer
  subject                   = var.gcp_service_account_unique_id
  audience                  = [local.token_exchange_audience]
}

resource "azurerm_role_assignment" "openai_user" {
  scope                = azurerm_cognitive_account.foundry.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_user_assigned_identity.gcp.principal_id
  principal_type       = "ServicePrincipal"
}
