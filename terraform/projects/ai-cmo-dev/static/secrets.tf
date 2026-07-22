##########################################
### Secret Manager - no shared module exists for this yet,
### so these stay as plain resources (unchanged from before),
### just re-pointed at the module-owned KMS key.
###########################################


resource "google_secret_manager_secret" "sales_agent_service_secret" {
  secret_id = "sales-agent-service-env"
  project   = local.gcp_project_id

  replication {
    user_managed {
      replicas {
        location = var.region
        customer_managed_encryption {
          kms_key_name = module.storage.bucket_key_id
        }
      }
    }
  }

  labels = {
    environment = var.envname
    managed_by  = "terraform"
  }
}




# resource "google_secret_manager_secret" "aicoedev_salesagent_ssl_private_key" {
#   secret_id = "aicoedev-salesagent-ssl-private-key"
#   project   = local.gcp_project_id

#   replication {
#     user_managed {
#       replicas {
#         location = var.region
#         customer_managed_encryption {
#           kms_key_name = module.storage.bucket_key_id
#         }
#       }
#     }
#   }

#   labels = {
#     environment = var.envname
#     managed_by  = "terraform"
#   }
# }

# resource "google_secret_manager_secret" "aicoedev_salesagent_ssl_certificate" {
#   secret_id = "aicoedev-salesagent-ssl-certificate"
#   project   = local.gcp_project_id

#   replication {
#     user_managed {
#       replicas {
#         location = var.region
#         customer_managed_encryption {
#           kms_key_name = module.storage.bucket_key_id
#         }
#       }
#     }
#   }

#   labels = {
#     environment = var.envname
#     managed_by  = "terraform"
#   }
# }

# resource "google_secret_manager_secret" "aicoedev_salesagent_csr" {
#   secret_id = "aicoedev-salesagent-csr"
#   project   = local.gcp_project_id

#   replication {
#     user_managed {
#       replicas {
#         location = var.region
#         customer_managed_encryption {
#           kms_key_name = module.storage.bucket_key_id
#         }
#       }
#     }
#   }

#   labels = {
#     environment = var.envname
#     managed_by  = "terraform"
#   }
# }

# resource "google_secret_manager_secret" "aicoedev_aihub_ssl_private_key" {
#   secret_id = "aicoedev-aihub-ssl-private-key"
#   project   = local.gcp_project_id

#   replication {
#     user_managed {
#       replicas {
#         location = var.region
#         customer_managed_encryption {
#           kms_key_name = module.storage.bucket_key_id
#         }
#       }
#     }
#   }

#   labels = {
#     environment = var.envname
#     managed_by  = "terraform"
#   }
# }

# resource "google_secret_manager_secret" "aicoedev_aihub_ssl_certificate" {
#   secret_id = "aicoedev-aihub-ssl-certificate"
#   project   = local.gcp_project_id

#   replication {
#     user_managed {
#       replicas {
#         location = var.region
#         customer_managed_encryption {
#           kms_key_name = module.storage.bucket_key_id
#         }
#       }
#     }
#   }

#   labels = {
#     environment = var.envname
#     managed_by  = "terraform"
#   }
# }

# resource "google_secret_manager_secret" "aicoedev_aihub_csr" {
#   secret_id = "aicoedev-aihub-csr"
#   project   = local.gcp_project_id

#   replication {
#     user_managed {
#       replicas {
#         location = var.region
#         customer_managed_encryption {
#           kms_key_name = module.storage.bucket_key_id
#         }
#       }
#     }
#   }

#   labels = {
#     environment = var.envname
#     managed_by  = "terraform"
#   }
# }
 