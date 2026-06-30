# Project-owned BigQuery dataset and table definitions for aicoesandox.
# Consumed by module.bigquery in main.tf via local.bigquery_datasets.

locals {
  bigquery_datasets = {
    translation = {
      dataset_id = "${local.resource_prefix}_translation_dataset"
      tables = {
        translation_jobs = {
          table_id = "translation_jobs"
          schema   = jsonencode([
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
          deletion_protection      = true
          require_partition_filter = false
          partitioning_type        = "DAY"
          partitioning_field       = "submitted_at"
          clustering               = ["status","job_id"]
        }
        translation_costs = {
          table_id = "translation_costs"
          schema   = jsonencode([
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
          deletion_protection      = true
        }
        dlp_mappings = {
          table_id = "dlp_mappings"
          schema   = jsonencode([
    { name = "job_id", type = "STRING", mode = "REQUIRED" },
    { name = "chunk_index", type = "INTEGER", mode = "REQUIRED" },
    { name = "token", type = "STRING", mode = "REQUIRED" },
    { name = "original_value", type = "STRING", mode = "REQUIRED" },
    { name = "info_type", type = "STRING", mode = "NULLABLE" },
    { name = "masked_at", type = "TIMESTAMP", mode = "NULLABLE" }
  ])
          deletion_protection      = true
        }
        translation_reviews = {
          table_id = "translation_reviews"
          schema   = jsonencode([
    {"name": "review_id", "type": "STRING", "mode": "REQUIRED"},
    {"name": "job_id", "type": "STRING", "mode": "REQUIRED"},
    {"name": "rating", "type": "INT64", "mode": "REQUIRED"},
    {"name": "comment", "type": "STRING", "mode": "NULLABLE"},
    {"name": "reviewer_email", "type": "STRING", "mode": "REQUIRED"},
    {"name": "created_at", "type": "TIMESTAMP", "mode": "REQUIRED"},
    {"name": "updated_at", "type": "TIMESTAMP", "mode": "REQUIRED"}
  ])
          deletion_protection      = true
        }
      }
    }
    sales_agent = {
      dataset_id = "${local.resource_prefix}_sales_agent_dataset"
      tables = {
        agent_telemetry = {
          table_id = "agent_telemetry"
          schema   = jsonencode([
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
          deletion_protection      = true
          require_partition_filter = false
          partitioning_type        = "DAY"
          partitioning_field       = "created_at"
        }
        catalog_build_jobs = {
          table_id = "catalog_build_jobs"
          schema   = jsonencode([
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
          deletion_protection      = true
          require_partition_filter = false
          partitioning_type        = "DAY"
          partitioning_field       = "created_at"
        }
        research_requests = {
          table_id = "research_requests"
          schema   = jsonencode([
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
          deletion_protection      = true
          require_partition_filter = false
          partitioning_type        = "DAY"
          partitioning_field       = "created_at"
        }
        cost_attribution = {
          table_id = "cost_attribution"
          schema   = jsonencode([
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
          deletion_protection      = true
          require_partition_filter = false
          partitioning_type        = "DAY"
          partitioning_field       = "created_at"
        }
        users_feedback = {
          table_id = "users_feedback"
          schema   = jsonencode([
    { name = "job_id", type = "STRING", mode = "REQUIRED" },
    { name = "user_email", type = "STRING", mode = "REQUIRED" },
    { name = "feedback", type = "STRING", mode = "NULLABLE" },
  ])
          deletion_protection      = true
        }
      }
    }
    contract_management = {
      dataset_id = "${local.resource_prefix}_contract_management"
      tables = {
        chatfeedback = {
          table_id = "chatfeedback"
          schema   = jsonencode([
    { name = "message_id", type = "STRING", mode = "REQUIRED" },
    { name = "session_id", type = "STRING", mode = "REQUIRED" },
    { name = "feedback", type = "STRING", mode = "REQUIRED" },
    { name = "created_at", type = "TIMESTAMP", mode = "NULLABLE" }
  ])
        }
        chat_history = {
          table_id = "chat_history"
          schema   = jsonencode([
    { name = "session_id", type = "STRING", mode = "REQUIRED" },
    { name = "history", type = "STRING", mode = "REQUIRED" },
    { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" },
    { name = "updated_at", type = "TIMESTAMP", mode = "NULLABLE" }
  ])
        }
        contract = {
          table_id = "contract"
          schema   = jsonencode([
    { name = "contract_id", type = "STRING", mode = "REQUIRED" },
    { name = "title", type = "STRING", mode = "NULLABLE" },
    { name = "type", type = "STRING", mode = "NULLABLE" },
    { name = "version", type = "STRING", mode = "NULLABLE" },
    { name = "effective_date", type = "DATE", mode = "NULLABLE" },
    { name = "expiry_date", type = "DATE", mode = "NULLABLE" },
    { name = "renewal_date", type = "DATE", mode = "NULLABLE" },
    { name = "notice_period", type = "INTEGER", mode = "NULLABLE" },
    { name = "language", type = "STRING", mode = "NULLABLE" },
    { name = "uploaded_by", type = "STRING", mode = "NULLABLE" },
    { name = "gcs_path", type = "STRING", mode = "NULLABLE" },
    { name = "sha256", type = "STRING", mode = "NULLABLE" },
 
    {
      name = "summary",
      type = "RECORD",
      mode = "NULLABLE",
      fields = [
        { name = "short", type = "STRING", mode = "NULLABLE" },
        { name = "medium", type = "STRING", mode = "NULLABLE" },
        { name = "long", type = "STRING", mode = "NULLABLE" }
      ]
    },
 
    { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" },
    { name = "updated_at", type = "TIMESTAMP", mode = "NULLABLE" }
  ])
        }
        contract_type_config = {
          table_id = "contract_type_config"
          schema   = jsonencode([
    { name = "contract_type", type = "STRING", mode = "REQUIRED" },
    { name = "description", type = "STRING", mode = "NULLABLE" },
    { name = "extraction_fields", type = "JSON", mode = "NULLABLE" },
    { name = "created_at", type = "TIMESTAMP", mode = "NULLABLE" },
    { name = "updated_at", type = "TIMESTAMP", mode = "NULLABLE" }
  ])
        }
        conversation_log = {
          table_id = "conversation_log"
          schema   = jsonencode([
    { name = "session_id", type = "STRING", mode = "REQUIRED" },
    { name = "message_id", type = "STRING", mode = "REQUIRED" },
    { name = "user_query", type = "STRING", mode = "REQUIRED" },
    { name = "condensed_query", type = "STRING", mode = "REQUIRED" },
    { name = "is_non_english", type = "BOOLEAN", mode = "REQUIRED" },
    { name = "is_offtopic", type = "BOOLEAN", mode = "REQUIRED" },
    { name = "sql_generated", type = "STRING", mode = "NULLABLE" },
    { name = "draft_answer", type = "STRING", mode = "NULLABLE" },
    { name = "final_answer", type = "STRING", mode = "REQUIRED" },
    { name = "security_violation", type = "BOOLEAN", mode = "REQUIRED" },
    { name = "violation_reason", type = "STRING", mode = "NULLABLE" },
    { name = "citations", type = "STRING", mode = "NULLABLE" },
    { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" },
    { name = "opik_trace_id", type = "STRING", mode = "NULLABLE" },
    { name = "feedback", type = "STRING", mode = "NULLABLE" }
  ])
        }
        extracted_field = {
          table_id = "extracted_field"
          schema   = jsonencode([
    { name = "contract_id", type = "STRING", mode = "REQUIRED" },
    { name = "data", type = "JSON", mode = "NULLABLE" },
    { name = "reviewed_by", type = "STRING", mode = "NULLABLE" },
    { name = "review_timestamp", type = "TIMESTAMP", mode = "NULLABLE" }
  ])
        }
      }
    }
    billing = {
      dataset_id = "${local.resource_prefix}_billing_dataset"
      tables = {
      }
    }
  }
}
