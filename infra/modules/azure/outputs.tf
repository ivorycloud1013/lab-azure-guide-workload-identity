output "foundry_endpoint" {
  description = "Foundry 리소스 endpoint"
  value       = azurerm_cognitive_account.foundry.endpoint
}

output "foundry_openai_endpoint" {
  description = "Azure OpenAI 호환 endpoint (https://<name>.openai.azure.com)"
  value       = "https://${azurerm_cognitive_account.foundry.custom_subdomain_name}.openai.azure.com"
}

output "deployment_name" {
  description = "모델 배포 이름"
  value       = azurerm_cognitive_deployment.image.name
}

output "uami_client_id" {
  description = "토큰 교환 시 client_id 로 사용할 UAMI Client ID"
  value       = azurerm_user_assigned_identity.gcp.client_id
}

output "uami_principal_id" {
  description = "UAMI Object(principal) ID"
  value       = azurerm_user_assigned_identity.gcp.principal_id
}

output "tenant_id" {
  description = "UAMI 가 속한 Entra ID tenant"
  value       = azurerm_user_assigned_identity.gcp.tenant_id
}
