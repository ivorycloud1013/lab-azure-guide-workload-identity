variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "service_account_id" {
  description = "생성할 Service Account ID (email 의 @ 앞부분)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.service_account_id))
    error_message = "service_account_id 는 6~30자, 소문자/숫자/하이픈이며 소문자로 시작해야 합니다."
  }
}
