#### Project-owned BigQuery dataset and table definitions for dev.
#### Consumed by module.bigquery in main.tf via local.bigquery_datasets.
#### Schemas below are copied 1:1 from the old infra/bq.tf so the plan is a
#### pure state move, with nothing added (no partitioning/clustering/extra
#### deletion_protection that aicoesandox has picked up since).
### 
###locals {
###  bigquery_datasets = {
###    translation = {
###      dataset_id = "${local.resource_prefix}_translation_dataset"
###      tables = {
###        translation_jobs = {
###          table_id = "translation_jobs"
###          schema = jsonencode([
###            { name = "job_id", type = "STRING", mode = "REQUIRED" },
###            { name = "status", type = "STRING", mode = "REQUIRED" },
###            { name = "source_document", type = "STRING", mode = "NULLABLE" },
###            { name = "translation_config", type = "STRING", mode = "NULLABLE" },
###            { name = "cost_attribution", type = "STRING", mode = "NULLABLE" },
###            { name = "result", type = "STRING", mode = "NULLABLE" },
###            { name = "error_message", type = "STRING", mode = "NULLABLE" },
###            { name = "source_hash", type = "STRING", mode = "NULLABLE" },
###            { name = "submitted_at", type = "TIMESTAMP", mode = "REQUIRED" },
###            { name = "completed_at", type = "TIMESTAMP", mode = "NULLABLE" }
###          ])
###        }
###        translation_costs = {
###          table_id = "translation_costs"
###          schema = jsonencode([
###            { name = "job_id", type = "STRING", mode = "REQUIRED" },
###            { name = "user_id", type = "STRING", mode = "NULLABLE" },
###            { name = "business_unit", type = "STRING", mode = "NULLABLE" },
###            { name = "organization", type = "STRING", mode = "NULLABLE" },
###            { name = "model_id", type = "STRING", mode = "NULLABLE" },
###            { name = "intent", type = "STRING", mode = "NULLABLE" },
###            { name = "input_tokens", type = "INTEGER", mode = "NULLABLE" },
###            { name = "output_tokens", type = "INTEGER", mode = "NULLABLE" },
###            { name = "cost_usd", type = "FLOAT", mode = "NULLABLE" },
###            { name = "timestamp", type = "TIMESTAMP", mode = "NULLABLE" }
###          ])
###        }
###        dlp_mappings = {
###          table_id = "dlp_mappings"
###          schema = jsonencode([
###            { name = "job_id", type = "STRING", mode = "REQUIRED" },
###            { name = "chunk_index", type = "INTEGER", mode = "REQUIRED" },
###            { name = "token", type = "STRING", mode = "REQUIRED" },
###            { name = "original_value", type = "STRING", mode = "REQUIRED" },
###            { name = "info_type", type = "STRING", mode = "NULLABLE" },
###            { name = "masked_at", type = "TIMESTAMP", mode = "NULLABLE" }
###          ])
###        }
###        translation_reviews = {
###          table_id = "translation_reviews"
###          schema = jsonencode([
###            { "name" : "review_id", "type" : "STRING", "mode" : "REQUIRED" },
###            { "name" : "job_id", "type" : "STRING", "mode" : "REQUIRED" },
###            { "name" : "rating", "type" : "INT64", "mode" : "REQUIRED" },
###            { "name" : "comment", "type" : "STRING", "mode" : "NULLABLE" },
###            { "name" : "reviewer_email", "type" : "STRING", "mode" : "REQUIRED" },
###            { "name" : "created_at", "type" : "TIMESTAMP", "mode" : "REQUIRED" },
###            { "name" : "updated_at", "type" : "TIMESTAMP", "mode" : "REQUIRED" }
###          ])
###          deletion_protection = true
###        }
###      }
###    }
###    sales_agent = {
###      dataset_id = "${local.resource_prefix}_sales_agent_dataset"
###      tables = {
###        cost_attribution = {
###          table_id = "cost_attribution"
###          schema = jsonencode([
###            { name = "job_execution_id", type = "STRING", mode = "REQUIRED" },
###            { name = "username", type = "STRING", mode = "NULLABLE" },
###            { name = "email", type = "STRING", mode = "NULLABLE" },
###            { name = "business_unit", type = "STRING", mode = "NULLABLE" },
###            { name = "model_version", type = "STRING", mode = "NULLABLE" },
###            { name = "temperature", type = "FLOAT", mode = "NULLABLE" },
###            { name = "prompt_template_version", type = "STRING", mode = "NULLABLE" },
###            { name = "input_tokens", type = "INTEGER", mode = "NULLABLE" },
###            { name = "output_tokens", type = "INTEGER", mode = "NULLABLE" },
###            { name = "total_tokens", type = "INTEGER", mode = "NULLABLE" },
###            { name = "latency_seconds", type = "FLOAT", mode = "NULLABLE" },
###            { name = "cost_usd", type = "FLOAT", mode = "NULLABLE" },
###            { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" }
###          ])
###        }
###        research_requests = {
###          table_id = "research_requests"
###          schema = jsonencode([
###            { name = "job_execution_id", type = "STRING", mode = "REQUIRED" },
###            { name = "company_name", type = "STRING", mode = "REQUIRED" },
###            { name = "status", type = "STRING", mode = "REQUIRED" },
###            { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" },
###            { name = "updated_at", type = "TIMESTAMP", mode = "REQUIRED" },
###            { name = "gcs_uri", type = "STRING", mode = "NULLABLE" },
###            { name = "error_message", type = "STRING", mode = "NULLABLE" },
###            { name = "metadata", type = "JSON", mode = "NULLABLE" },
###            { name = "progress", type = "INTEGER", mode = "NULLABLE" },
###            { name = "current_step", type = "STRING", mode = "NULLABLE" }
###          ])
###        }
###        agent_telemetry = {
###          table_id = "agent_telemetry"
###          schema = jsonencode([
###            { name = "record_id", type = "STRING", mode = "REQUIRED" },
###            { name = "job_execution_id", type = "STRING", mode = "REQUIRED" },
###            { name = "agent_name", type = "STRING", mode = "REQUIRED" },
###            { name = "agent_type", type = "STRING", mode = "NULLABLE" },
###            { name = "latency_ms", type = "INTEGER", mode = "NULLABLE" },
###            { name = "tokens_input", type = "INTEGER", mode = "NULLABLE" },
###            { name = "tokens_output", type = "INTEGER", mode = "NULLABLE" },
###            { name = "model_used", type = "STRING", mode = "NULLABLE" },
###            { name = "cost_usd", type = "FLOAT", mode = "NULLABLE" },
###            { name = "success", type = "BOOLEAN", mode = "NULLABLE" },
###            { name = "error_message", type = "STRING", mode = "NULLABLE" },
###            { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" },
###          ])
###        }
###        catalog_build_jobs = {
###          table_id = "catalog_build_jobs"
###          schema = jsonencode([
###            { name = "job_id", type = "STRING", mode = "REQUIRED" },
###            { name = "operation", type = "STRING", mode = "REQUIRED" },
###            { name = "status", type = "STRING", mode = "REQUIRED" },
###            { name = "progress", type = "INTEGER", mode = "NULLABLE" },
###            { name = "current_step", type = "STRING", mode = "NULLABLE" },
###            { name = "version_id", type = "STRING", mode = "NULLABLE" },
###            { name = "error_message", type = "STRING", mode = "NULLABLE" },
###            { name = "user_email", type = "STRING", mode = "NULLABLE" },
###            { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" },
###            { name = "updated_at", type = "TIMESTAMP", mode = "REQUIRED" },
###            { name = "metadata", type = "JSON", mode = "NULLABLE" }
###          ])
###        }
###      }
###    }
###  }
###}
### 
######


# Project-owned BigQuery dataset and table definitions for dev.
# Consumed by module.bigquery in main.tf via local.bigquery_datasets.
# Schemas below are copied 1:1 from the old infra/bq.tf. deletion_protection
# is explicitly set to true on every table because the google provider's
# default for this attribute is true, and dev's tables were all created
# under that default - the module's own default is false, so leaving it
# unset here would show as "true -> false" on every table.

locals {
  bigquery_datasets = {
    translation = {
      dataset_id = "${local.resource_prefix}_translation_dataset"
      tables = {
        translation_jobs = {
          table_id = "translation_jobs"
          schema = jsonencode([
            { name = "job_id", type = "STRING", mode = "REQUIRED" },
            { name = "status", type = "STRING", mode = "REQUIRED" },
            { name = "source_document", type = "STRING", mode = "NULLABLE" },
            { name = "translation_config", type = "STRING", mode = "NULLABLE" },
            { name = "cost_attribution", type = "STRING", mode = "NULLABLE" },
            { name = "result", type = "STRING", mode = "NULLABLE" },
            { name = "error_message", type = "STRING", mode = "NULLABLE" },
            { name = "source_hash", type = "STRING", mode = "NULLABLE" },
            { name = "submitted_at", type = "TIMESTAMP", mode = "REQUIRED" },
            { name = "completed_at", type = "TIMESTAMP", mode = "NULLABLE" }
          ])
          deletion_protection = true
        }
        translation_costs = {
          table_id = "translation_costs"
          schema = jsonencode([
            { name = "job_id", type = "STRING", mode = "REQUIRED" },
            { name = "user_id", type = "STRING", mode = "NULLABLE" },
            { name = "business_unit", type = "STRING", mode = "NULLABLE" },
            { name = "organization", type = "STRING", mode = "NULLABLE" },
            { name = "model_id", type = "STRING", mode = "NULLABLE" },
            { name = "intent", type = "STRING", mode = "NULLABLE" },
            { name = "input_tokens", type = "INTEGER", mode = "NULLABLE" },
            { name = "output_tokens", type = "INTEGER", mode = "NULLABLE" },
            { name = "cost_usd", type = "FLOAT", mode = "NULLABLE" },
            { name = "timestamp", type = "TIMESTAMP", mode = "NULLABLE" }
          ])
          deletion_protection = true
        }
        dlp_mappings = {
          table_id = "dlp_mappings"
          schema = jsonencode([
            { name = "job_id", type = "STRING", mode = "REQUIRED" },
            { name = "chunk_index", type = "INTEGER", mode = "REQUIRED" },
            { name = "token", type = "STRING", mode = "REQUIRED" },
            { name = "original_value", type = "STRING", mode = "REQUIRED" },
            { name = "info_type", type = "STRING", mode = "NULLABLE" },
            { name = "masked_at", type = "TIMESTAMP", mode = "NULLABLE" }
          ])
          deletion_protection = true
        }
        translation_reviews = {
          table_id = "translation_reviews"
          schema = jsonencode([
            { "name" : "review_id", "type" : "STRING", "mode" : "REQUIRED" },
            { "name" : "job_id", "type" : "STRING", "mode" : "REQUIRED" },
            { "name" : "rating", "type" : "INT64", "mode" : "REQUIRED" },
            { "name" : "comment", "type" : "STRING", "mode" : "NULLABLE" },
            { "name" : "reviewer_email", "type" : "STRING", "mode" : "REQUIRED" },
            { "name" : "created_at", "type" : "TIMESTAMP", "mode" : "REQUIRED" },
            { "name" : "updated_at", "type" : "TIMESTAMP", "mode" : "REQUIRED" }
          ])
          deletion_protection = true
        }
      }
    }
    sales_agent = {
      dataset_id = "${local.resource_prefix}_sales_agent_dataset"
      tables = {
        cost_attribution = {
          table_id = "cost_attribution"
          schema = jsonencode([
            { name = "job_execution_id", type = "STRING", mode = "REQUIRED" },
            { name = "username", type = "STRING", mode = "NULLABLE" },
            { name = "email", type = "STRING", mode = "NULLABLE" },
            { name = "business_unit", type = "STRING", mode = "NULLABLE" },
            { name = "model_version", type = "STRING", mode = "NULLABLE" },
            { name = "temperature", type = "FLOAT", mode = "NULLABLE" },
            { name = "prompt_template_version", type = "STRING", mode = "NULLABLE" },
            { name = "input_tokens", type = "INTEGER", mode = "NULLABLE" },
            { name = "output_tokens", type = "INTEGER", mode = "NULLABLE" },
            { name = "total_tokens", type = "INTEGER", mode = "NULLABLE" },
            { name = "latency_seconds", type = "FLOAT", mode = "NULLABLE" },
            { name = "cost_usd", type = "FLOAT", mode = "NULLABLE" },
            { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" }
          ])
          deletion_protection = true
        }
        research_requests = {
          table_id = "research_requests"
          schema = jsonencode([
            { name = "job_execution_id", type = "STRING", mode = "REQUIRED" },
            { name = "company_name", type = "STRING", mode = "REQUIRED" },
            { name = "status", type = "STRING", mode = "REQUIRED" },
            { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" },
            { name = "updated_at", type = "TIMESTAMP", mode = "REQUIRED" },
            { name = "gcs_uri", type = "STRING", mode = "NULLABLE" },
            { name = "error_message", type = "STRING", mode = "NULLABLE" },
            { name = "metadata", type = "JSON", mode = "NULLABLE" },
            { name = "progress", type = "INTEGER", mode = "NULLABLE" },
            { name = "current_step", type = "STRING", mode = "NULLABLE" }
          ])
          deletion_protection = true
        }
        agent_telemetry = {
          table_id = "agent_telemetry"
          schema = jsonencode([
            { name = "record_id", type = "STRING", mode = "REQUIRED" },
            { name = "job_execution_id", type = "STRING", mode = "REQUIRED" },
            { name = "agent_name", type = "STRING", mode = "REQUIRED" },
            { name = "agent_type", type = "STRING", mode = "NULLABLE" },
            { name = "latency_ms", type = "INTEGER", mode = "NULLABLE" },
            { name = "tokens_input", type = "INTEGER", mode = "NULLABLE" },
            { name = "tokens_output", type = "INTEGER", mode = "NULLABLE" },
            { name = "model_used", type = "STRING", mode = "NULLABLE" },
            { name = "cost_usd", type = "FLOAT", mode = "NULLABLE" },
            { name = "success", type = "BOOLEAN", mode = "NULLABLE" },
            { name = "error_message", type = "STRING", mode = "NULLABLE" },
            { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" },
          ])
          deletion_protection = true
        }
        catalog_build_jobs = {
          table_id = "catalog_build_jobs"
          schema = jsonencode([
            { name = "job_id", type = "STRING", mode = "REQUIRED" },
            { name = "operation", type = "STRING", mode = "REQUIRED" },
            { name = "status", type = "STRING", mode = "REQUIRED" },
            { name = "progress", type = "INTEGER", mode = "NULLABLE" },
            { name = "current_step", type = "STRING", mode = "NULLABLE" },
            { name = "version_id", type = "STRING", mode = "NULLABLE" },
            { name = "error_message", type = "STRING", mode = "NULLABLE" },
            { name = "user_email", type = "STRING", mode = "NULLABLE" },
            { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" },
            { name = "updated_at", type = "TIMESTAMP", mode = "REQUIRED" },
            { name = "metadata", type = "JSON", mode = "NULLABLE" }
          ])
          deletion_protection = true
        }
      }
    }
  }
}
 