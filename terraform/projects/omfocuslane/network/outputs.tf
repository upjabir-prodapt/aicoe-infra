output "aicoe_network" {
  value = module.network_base.aicoe_network
}

output "aicoe_network_id" {
  value = module.network_base.aicoe_network_id
}

output "aicoe_subnet_name" {
  value = module.network_base.aicoe_subnet_name
}

output "aicoe_proxy_only_subnet_name" {
  value = module.network_base.aicoe_proxy_only_subnet_name
}

output "aicoe_staticip_ilb" {
  value = module.network_connectivity.aicoe_staticip_ilb
}

output "aicoe_subnet_cidr" {
  value = module.network_base.aicoe_subnet_cidr
}

output "psc_endpoint_ip" {
  value = module.network_connectivity.psc_endpoint_ip
}

output "dns_zone_name" {
  value = module.network_connectivity.dns_zone_name
}

output "aicoe_staticip_ilb_salesagent" {
  value = module.network_connectivity.aicoe_staticip_ilb_salesagent
}

output "aicoe_static_ilb_frontend_ip" {
  value = module.network_connectivity.aicoe_static_ilb_frontend_ip
}

output "vector_search_psc_ip" {
  value = module.network_connectivity.vector_search_psc_ip
}

output "vector_search_psc_ip_self_link" {
  value = module.network_connectivity.vector_search_psc_ip_self_link
}
