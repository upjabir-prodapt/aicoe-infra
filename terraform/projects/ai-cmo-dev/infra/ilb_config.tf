locals {
  ilb_services = {
    
    salesagent = {
      cloud_run_service_name = var.cloud_run_service_name
      ip_address              = local.salesagent_ilb_ip
      certificate_secret      = "salesagent-ssl-certificate"
      private_key_secret      = "salesagent-ssl-private-key"
    }
  }
}