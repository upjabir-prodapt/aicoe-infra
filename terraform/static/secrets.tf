###########################################
### Secret Manager for Translation agent ###########
###########################################

import{
    to = google_secret_manager_secret.translation_service_secret
    id = "projects/${var.project}${var.envname}/secrets/translation-service-env"
}
resource "google_secret_manager_secret" "translation_service_secret" {
  secret_id = "translation-service-env"
  project = "${var.project}${var.envname}"

  replication {
    user_managed {
        replicas {
            location = var.region
            customer_managed_encryption {
            kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
            }
    }
  }
}
labels = {
    environment = var.envname
    managed_by = "terraform"
}
}

# ###########################################
# ### Secret Manager for Sales agent ###########
# ###########################################
 
# resource "google_secret_manager_secret" "sales_agent_service_secret" {
#   secret_id = "sales-agent-service-env"
#   project = "${var.project}${var.envname}"

#   replication {
#     user_managed {
#        replicas {
#             location = var.region
#             customer_managed_encryption {
#             kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
#             }
#        }
#     }
#   }
#    labels = {
#      environment = var.envname
#      managed_by = "terraform"
#  }
# }
