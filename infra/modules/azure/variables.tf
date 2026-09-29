variable "resource_group_name" {
  description = "Resource group 이름"
  type        = string
}

variable "location" {
  description = "Azure region (gpt-image-2 GlobalStandard 지원 region)"
  type        = string
}

variable "foundry_name" {
  description = "Foundry(AIServices) 리소스 이름. custom subdomain 으로도 사용되므로 전역 고유해야 함"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,62}[a-z0-9]$", var.foundry_name))
    error_message = "foundry_name 은 3~64자의 소문자/숫자/하이픈이어야 합니다."
  }
}

variable "deployment_name" {
  description = "모델 배포 이름 (API 호출 시 model 값)"
  type        = string
}

variable "model_name" {
  description = "배포할 모델 이름"
  type        = string
}

variable "model_version" {
  description = "모델 버전 (az cognitiveservices model list -l <region> 로 확인)"
  type        = string
}

variable "deployment_sku" {
  description = "배포 SKU"
  type        = string
}

variable "deployment_capacity" {
  description = "배포 capacity (region quota 이내)"
  type        = number

  validation {
    condition     = var.deployment_capacity >= 1
    error_message = "deployment_capacity 는 1 이상이어야 합니다."
  }
}

variable "identity_name" {
  description = "User-Assigned Managed Identity 이름"
  type        = string
}

variable "federated_credential_name" {
  description = "Federated Identity Credential 이름"
  type        = string
}

variable "gcp_service_account_unique_id" {
  description = "Google ID token 의 sub 로 들어오는 GCP SA unique ID"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{21}$", var.gcp_service_account_unique_id))
    error_message = "GCP SA unique ID 는 21자리 숫자입니다."
  }
}

variable "allowed_ip_ranges" {
  description = "Foundry 에 접근 허용할 공인 IP/CIDR. 비어 있으면 모든 네트워크 허용"
  type        = list(string)
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
}
