resource "google_bigquery_dataset" "aicoe_translation_dataset" {
  dataset_id               = "${var.project}${var.envname}_translation_dataset"
  location                 = var.region
  project                  = "${var.project}${var.envname}"

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

# Cost attribution table
resource "google_bigquery_table" "translation_costs" {
  dataset_id = google_bigquery_dataset.aicoe_translation_dataset.dataset_id
  table_id   = "translation_costs"
  project    = google_bigquery_dataset.aicoe_translation_dataset.project

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

# DLP tokens table
resource "google_bigquery_table" "dlp_mappings" {
  dataset_id = google_bigquery_dataset.aicoe_translation_dataset.dataset_id
  table_id   = "dlp_mappings"
  project    = google_bigquery_dataset.aicoe_translation_dataset.project

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

# Cost attribution table for Sales agent
resource "google_bigquery_table" "cost_attribution" {
  dataset_id = google_bigquery_dataset.aicoe_sales_agent_dataset.dataset_id
  table_id   = "cost_attribution"
  project    = google_bigquery_dataset.aicoe_sales_agent_dataset.project

  schema = jsonencode([
    { name = "job_execution_id", type = "STRING", mode = "REQUIRED" },
    { name = "model_version", type = "STRING", mode = "NULLABLE" },
    { name = "temperature", type = "FLOAT", mode = "NULLABLE" },
    { name = "prompt_template_version", type = "STRING", mode = "NULLABLE" },
    { name = "input_tokens", type = "INTEGER", mode = "NULLABLE" },
    { name = "output_tokens", type = "INTEGER", mode = "NULLABLE" },
    { name = "total_tokens", type = "INTEGER", mode = "NULLABLE" },
    { name = "latency_seconds", type = "FLOAT", mode = "NULLABLE" },
    { name = "source_domains", type = "JSON", mode = "NULLABLE" },
    { name = "cost_usd", type = "FLOAT", mode = "NULLABLE" },
    { name = "created_at", type = "TIMESTAMP", mode = "REQUIRED" }
  ])
}

# Research requests table
resource "google_bigquery_table" "research_requests" {
  dataset_id = google_bigquery_dataset.aicoe_sales_agent_dataset.dataset_id
  table_id   = "research_requests"
  project    = google_bigquery_dataset.aicoe_sales_agent_dataset.project

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

# #sales agent telemetry table
resource "google_bigquery_table" "agent_telemetry" {
  dataset_id = google_bigquery_dataset.aicoe_sales_agent_dataset.dataset_id
  table_id   = "agent_telemetry"
  project    = google_bigquery_dataset.aicoe_sales_agent_dataset.project
  
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
