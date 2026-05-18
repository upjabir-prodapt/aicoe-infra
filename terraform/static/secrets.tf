###########################################
### Secret Manager for Sales agent ###########
###########################################

resource "google_secret_manager_secret" "secret" {
  secret_id = "translation-service-env"
  project = "${var.project}${var.envname}"

  replication {
    auto {}
  }

  labels = {
    environment = "${var.envname}"
    managed_by = "terraform"
  }
}

###########################################
### Secret Manager for Sales agent ###########
###########################################
 
resource "google_secret_manager_secret" "secret" {
  secret_id = "sales-agent-service-env"
  project = "${var.project}${var.envname}"

  replication {
    auto {}
  }

  labels = {
    environment = "${var.envname}"
    managed_by = "terraform"
  }
}