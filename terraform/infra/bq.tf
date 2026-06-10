resource "google_bigquery_dataset" "aicoe_translation_dataset" {
  dataset_id               = "${var.project}${var.envname}_translation_dataset"
  location                 = var.region
  project                  = "${var.project}${var.envname}"

  # Optional safety flag: defaults to false if not set
  delete_contents_on_destroy = true

  labels = {
      env    = var.envname
      system = "${var.project}${var.envname}"
    }
}

# Translation jobs table
resource "google_bigquery_table" "translation_jobs" {
  dataset_id = google_bigquery_dataset.aicoe_translation_dataset.dataset_id
  table_id   = "translation_jobs"
  project    = google_bigquery_dataset.aicoe_translation_dataset.project
  deletion_protection = true
  require_partition_filter = false

  time_partitioning {
    type = "DAY"
    field = "submitted_at"
  }
  
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
}

# # Cost attribution table
resource "google_bigquery_table" "translation_costs" {
  dataset_id = google_bigquery_dataset.aicoe_translation_dataset.dataset_id
  table_id   = "translation_costs"
  project    = google_bigquery_dataset.aicoe_translation_dataset.project
  deletion_protection = true
  
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
}

# # DLP tokens table
resource "google_bigquery_table" "dlp_mappings" {
  dataset_id = google_bigquery_dataset.aicoe_translation_dataset.dataset_id
  table_id   = "dlp_mappings"
  project    = google_bigquery_dataset.aicoe_translation_dataset.project
  deletion_protection = true

  schema = jsonencode([
    { name = "job_id", type = "STRING", mode = "REQUIRED" },
    { name = "chunk_index", type = "INTEGER", mode = "REQUIRED" },
    { name = "token", type = "STRING", mode = "REQUIRED" },
    { name = "original_value", type = "STRING", mode = "REQUIRED" },
    { name = "info_type", type = "STRING", mode = "NULLABLE" },
    { name = "masked_at", type = "TIMESTAMP", mode = "NULLABLE" }
  ])
}

###########################Sales Agent Dataset#############################

resource "google_bigquery_dataset" "aicoe_sales_agent_dataset" {
  dataset_id               = "${var.project}${var.envname}_sales_agent_dataset"
  location                 = var.region
  project                  = "${var.project}${var.envname}"

  # Optional safety flag: defaults to false if not set
  delete_contents_on_destroy = true

  labels = {
      env    = var.envname
      system = "${var.project}${var.envname}"
    }
}

# #sales agent telemetry table
# import {
#   to = google_bigquery_table.agent_telemetry
#   id = "projects/aicoesandox/datasets/aicoesandox_sales_agent_dataset/tables/agent_telemetry"
# }
resource "google_bigquery_table" "agent_telemetry" {
  dataset_id = google_bigquery_dataset.aicoe_sales_agent_dataset.dataset_id
  table_id   = "agent_telemetry"
  project    = google_bigquery_dataset.aicoe_sales_agent_dataset.project
  deletion_protection = true
  require_partition_filter = false

  time_partitioning {
    type = "DAY"
    field = "created_at"
  }

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
}

#Catalog Build Jobs table
resource "google_bigquery_table" "catalog_build_jobs" {
  dataset_id = google_bigquery_dataset.aicoe_sales_agent_dataset.dataset_id
  table_id   = "catalog_build_jobs"
  project    = google_bigquery_dataset.aicoe_sales_agent_dataset.project
  deletion_protection = true
  require_partition_filter = false

  time_partitioning {
    type = "DAY"
    field = "created_at"
  }
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
}


# Research requests table
resource "google_bigquery_table" "research_requests" {
  dataset_id = google_bigquery_dataset.aicoe_sales_agent_dataset.dataset_id
  table_id   = "research_requests"
  project    = google_bigquery_dataset.aicoe_sales_agent_dataset.project
  deletion_protection = true
  require_partition_filter = false

  time_partitioning {
    type = "DAY"
    field = "created_at"
  }

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
}

# Cost attribution table for Sales agent
resource "google_bigquery_table" "cost_attribution" {
  dataset_id = google_bigquery_dataset.aicoe_sales_agent_dataset.dataset_id
  table_id   = "cost_attribution"
  project    = google_bigquery_dataset.aicoe_sales_agent_dataset.project
  deletion_protection = true
  require_partition_filter = false

  time_partitioning {
    type = "DAY"
    field = "created_at"
  }
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
}




###########################Contract Management Dataset#############################
resource "google_bigquery_dataset" "contract_management_dataset" {
  dataset_id = "${var.project}${var.envname}_contract_management"
  project    = "${var.project}${var.envname}"
  location   = var.region
 
  delete_contents_on_destroy = true
 
  labels = {
    env    = var.envname
    system = "${var.project}${var.envname}"
  }
}
 
resource "google_bigquery_table" "chatfeedback" {
  dataset_id = google_bigquery_dataset.contract_management_dataset.dataset_id
  project    = google_bigquery_dataset.contract_management_dataset.project
  table_id   = "chatfeedback"
 
  schema = jsonencode([
    { name = "message_id", type = "STRING", mode = "REQUIRED" },
    { name = "session_id", type = "STRING", mode = "REQUIRED" },
    { name = "feedback", type = "STRING", mode = "REQUIRED" },
    { name = "created_at", type = "TIMESTAMP", mode = "NULLABLE" }
  ])
}
 
resource "google_bigquery_table" "chat_history" {
  dataset_id = google_bigquery_dataset.contract_management_dataset.dataset_id
  project    = google_bigquery_dataset.contract_management_dataset.project
  table_id   = "chat_history"
 
  schema = jsonencode([
    { name = "session_id", type = "STRING", mode = "REQUIRED" },
    { name = "history", type = "STRING", mode = "REQUIRED" },
    { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" },
    { name = "updated_at", type = "TIMESTAMP", mode = "NULLABLE" }
  ])
}
 
resource "google_bigquery_table" "contract" {
  dataset_id = google_bigquery_dataset.contract_management_dataset.dataset_id
  project    = google_bigquery_dataset.contract_management_dataset.project
  table_id   = "contract"
 
  schema = jsonencode([
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
 
resource "google_bigquery_table" "contract_type_config" {
  dataset_id = google_bigquery_dataset.contract_management_dataset.dataset_id
  project    = google_bigquery_dataset.contract_management_dataset.project
  table_id   = "contract_type_config"
 
  schema = jsonencode([
    { name = "contract_type", type = "STRING", mode = "REQUIRED" },
    { name = "description", type = "STRING", mode = "NULLABLE" },
    { name = "extraction_fields", type = "JSON", mode = "NULLABLE" },
    { name = "created_at", type = "TIMESTAMP", mode = "NULLABLE" },
    { name = "updated_at", type = "TIMESTAMP", mode = "NULLABLE" }
  ])
}
 
resource "google_bigquery_table" "conversation_log" {
  dataset_id = google_bigquery_dataset.contract_management_dataset.dataset_id
  project    = google_bigquery_dataset.contract_management_dataset.project
  table_id   = "conversation_log"
 
  schema = jsonencode([
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
 
resource "google_bigquery_table" "extracted_field" {
  dataset_id = google_bigquery_dataset.contract_management_dataset.dataset_id
  project    = google_bigquery_dataset.contract_management_dataset.project
  table_id   = "extracted_field"
 
  schema = jsonencode([
    { name = "contract_id", type = "STRING", mode = "REQUIRED" },
    { name = "data", type = "JSON", mode = "NULLABLE" },
    { name = "reviewed_by", type = "STRING", mode = "NULLABLE" },
    { name = "review_timestamp", type = "TIMESTAMP", mode = "NULLABLE" }
  ])
}

###########################Billing Dataset#############################
resource "google_bigquery_dataset" "aicoe_billing_dataset" {
  dataset_id               = "${var.project}${var.envname}_billing_dataset"
  location                 = var.region
  project                  = "${var.project}${var.envname}"

  # Optional safety flag: defaults to false if not set
  delete_contents_on_destroy = true

  labels = {
      env    = var.envname
      system = "${var.project}${var.envname}"
    }
}


 

