output "gcp_project_id" {
  value = var.gcp_project_id
}

output "gcp_service_account_id" {
  value = module.gcp.service_account_id
}

output "azure_tenant_id" {
  value = module.azure.tenant_id
}

output "azure_uami_client_id" {
  value = module.azure.uami_client_id
}

output "foundry_endpoint" {
  value = module.azure.foundry_openai_endpoint
}

output "foundry_deployment_name" {
  value = module.azure.deployment_name
}

output "gcp_service_account_email" {
  value = module.gcp.service_account_email
}

output "gcp_service_account_unique_id" {
  value = module.gcp.service_account_unique_id
}
