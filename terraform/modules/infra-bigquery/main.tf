resource "google_bigquery_dataset" "dataset" {
  for_each = var.datasets

  dataset_id                 = each.value.dataset_id
  location                   = var.region
  project                    = var.gcp_project_id
  delete_contents_on_destroy = true
  labels                     = var.labels
}

locals {
  tables = merge([
    for dataset_key, dataset in var.datasets : {
      for table_key, table in dataset.tables :
      "${dataset_key}.${table_key}" => merge(table, {
        dataset_key = dataset_key
      })
    }
  ]...)
}

resource "google_bigquery_table" "table" {
  for_each = local.tables

  dataset_id          = google_bigquery_dataset.dataset[each.value.dataset_key].dataset_id
  table_id            = each.value.table_id
  project             = var.gcp_project_id
  deletion_protection = lookup(each.value, "deletion_protection", false)
  schema              = each.value.schema

  require_partition_filter = lookup(each.value, "require_partition_filter", false)

  dynamic "time_partitioning" {
    for_each = lookup(each.value, "partitioning_field", null) != null ? [each.value] : []
    content {
      type  = lookup(time_partitioning.value, "partitioning_type", "DAY")
      field = time_partitioning.value.partitioning_field
    }
  }

  clustering = lookup(each.value, "clustering", null)
}
