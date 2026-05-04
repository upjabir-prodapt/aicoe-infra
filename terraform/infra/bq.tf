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
resource "google_bigquery_table" "cost_attribution" {
  dataset_id = google_bigquery_dataset.aicoe_translation_dataset.dataset_id
  table_id   = "cost_attribution"
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
resource "google_bigquery_table" "dlp_tokens" {
  dataset_id = google_bigquery_dataset.aicoe_translation_dataset.dataset_id
  table_id   = "dlp_tokens"
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

