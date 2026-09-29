# ---------- 공통 ----------
variable "name_prefix" {
  description = "리소스 이름 접두사"
  type        = string
  default     = "gcp-foundry-wif"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,40}$", var.name_prefix))
    error_message = "name_prefix 는 소문자로 시작하는 3~41자의 소문자/숫자/하이픈이어야 합니다."
  }
}

variable "tags" {
  description = "Azure 리소스 공통 태그"
  type        = map(string)
  default = {
    purpose = "gcp-azure-workload-identity-lab"
  }
}

# ---------- GCP ----------
variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_service_account_id" {
  description = "생성할 GCP Service Account ID"
  type        = string
  default     = "azure-foundry-caller"
}

# ---------- Azure ----------
variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "azure_location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "deployment_name" {
  description = "모델 배포 이름"
  type        = string
  default     = "gpt-image-2.5-flare"
}

variable "model_name" {
  description = "배포할 모델 이름"
  type        = string
  default     = "gpt-image-2.5-flare"
}

variable "model_version" {
  description = "모델 버전"
  type        = string
  default     = "2026-09-08"
}

variable "deployment_sku" {
  description = "배포 SKU (gpt-image 모델은 GlobalStandard)"
  type        = string
  default     = "GlobalStandard"
}

variable "deployment_capacity" {
  description = "배포 capacity (region quota 이내로 설정)"
  type        = number
  default     = 1
}

variable "allowed_ip_ranges" {
  description = "Foundry 접근 허용 공인 IP/CIDR (GCP egress IP 등). 비어 있으면 public 허용"
  type        = list(string)
  default     = []
}
