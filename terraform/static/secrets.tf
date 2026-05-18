###########################################
### Secret Manager for Sales agent ###########
###########################################

resource "google_secret_manager_secret" "translation_service_secret" {
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
 
resource "google_secret_manager_secret" "sales_agent_service_secret" {
  secret_id = "sales-agent-service-env"
  project = "${var.project}${var.envname}"

  replication {
    user_managed {
        replicas {
            location = var.region
        }
    }
  }

  labels = {
    environment = "${var.envname}"
    managed_by = "terraform"
  }
}