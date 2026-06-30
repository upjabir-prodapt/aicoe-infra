variable "gcp_project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "labels" {
  type        = map(string)
  description = "Canonical labels applied to label-capable resources"
}

variable "datasets" {
  type = map(object({
    dataset_id = string
    tables = map(object({
      table_id                 = string
      schema                   = string
      deletion_protection      = optional(bool, false)
      require_partition_filter = optional(bool, false)
      partitioning_type        = optional(string)
      partitioning_field       = optional(string)
      clustering               = optional(list(string))
    }))
  }))
  description = "BigQuery datasets and tables to create"
}
