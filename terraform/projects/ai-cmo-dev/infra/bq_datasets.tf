locals {
  bigquery_datasets = {
    sales_agent = {
      dataset_id = "sales_agent_dataset"
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
 