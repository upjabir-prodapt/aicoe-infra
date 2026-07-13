###locals {
###  ilb_services = {
###    translation = {
###      cloud_run_service_name = var.cloud_run_service_name
###      ip_address              = local.translation_ilb_ip
###      certificate_secret      = "aicoedev-translation-ssl-certificate"
###      private_key_secret      = "aicoedev-translation-ssl-private-key"
###    }
###    salesagent = {
###      cloud_run_service_name = var.cloud_run_service_name2
###      ip_address              = local.salesagent_ilb_ip
###      certificate_secret      = "aicoedev-salesagent-ssl-certificate"
###      private_key_secret      = "aicoedev-salesagent-ssl-private-key"
###    }
###    aihub = {
###      cloud_run_service_name = var.cloud_run_service_name3
###      ip_address              = local.frontend_ilb_ip
###      certificate_secret      = "aicoedev-aihub-ssl-certificate"
###      private_key_secret      = "aicoedev-aihub-ssl-private-key"
###    }
###  }
###}
 locals {
  ilb_services = {
    translation = {
      cloud_run_service_name = var.cloud_run_service_name
      ip_address              = local.translation_ilb_ip
      certificate_secret      = "aicoedev-translation-ssl-certificate"
      private_key_secret      = "aicoedev-translation-ssl-private-key"
      # Legacy resource was created as "aicoedev-translation-ilb-https-proxy"
      # (word order swapped vs the module's default pattern). Pin the name
      # here so terraform doesn't try to destroy/recreate it.
      https_proxy_name        = "${local.resource_prefix}-translation-ilb-https-proxy"
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
      # Legacy aihub url map fans traffic out by path to salesagent and
      # translation backends, with a "/api/" prefix rewrite on each.
      path_rules = [
        {
          paths               = ["/api/sales/*"]
          backend_service_key = "salesagent"
          path_prefix_rewrite = "/api/"
        },
        {
          paths               = ["/api/translation/*"]
          backend_service_key = "translation"
          path_prefix_rewrite = "/api/"
        }
      ]
    }
  }
}