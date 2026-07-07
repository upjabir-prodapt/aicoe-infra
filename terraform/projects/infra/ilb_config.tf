locals {
  ilb_services = {
    translation = {
      cloud_run_service_name = var.cloud_run_service_name
      ip_address              = local.translation_ilb_ip
      certificate_secret      = "aicoedev-translation-ssl-certificate"
      private_key_secret      = "aicoedev-translation-ssl-private-key"
    }
    salesagent = {
      cloud_run_service_name = var.cloud_run_service_name2
      ip_address              = local.salesagent_ilb_ip
      certificate_secret      = "aicoedev-salesagent-ssl-certificate"
      private_key_secret      = "aicoedev-salesagent-ssl-private-key"
    }
    aihub = {
      cloud_run_service_name = var.cloud_run_service_name3
      ip_address              = local.frontend_ilb_ip
      certificate_secret      = "aicoedev-aihub-ssl-certificate"
      private_key_secret      = "aicoedev-aihub-ssl-private-key"
    }
  }
}
 