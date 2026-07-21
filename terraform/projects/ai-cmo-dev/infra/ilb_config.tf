locals {
  ilb_services = {
    
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
        }
      ]
    }
  }
}