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
 

