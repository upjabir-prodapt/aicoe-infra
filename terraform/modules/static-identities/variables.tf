variable "gcp_project_id" {
  type = string
}

variable "service_accounts" {
  type = map(object({
    account_id                 = string
    display_name               = string
    roles                      = list(string)
    grant_roles_to_account_key = optional(string)
  }))
  description = "Service accounts to create and project IAM roles to grant"
}
