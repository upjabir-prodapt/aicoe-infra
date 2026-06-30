output "network_self_link" {
  value = module.network_base.network_self_link
}

output "network_id" {
  value = module.network_base.network_id
}

output "subnet_self_link" {
  value = module.network_base.subnet_self_link
}

output "proxy_only_subnet_self_link" {
  value = module.network_base.proxy_only_subnet_self_link
}

output "reserved_internal_addresses" {
  value = module.network_connectivity.reserved_internal_addresses
}

output "subnet_cidr_range" {
  value = module.network_base.subnet_cidr_range
}

output "psc_google_apis_ip" {
  value = module.network_connectivity.psc_google_apis_ip
}

output "googleapis_dns_zone_name" {
  value = module.network_connectivity.googleapis_dns_zone_name
}

output "internal_dns_zone_name" {
  value = module.network_connectivity.internal_dns_zone_name
}

output "regional_psc_addresses" {
  value = module.network_connectivity.regional_psc_addresses
}

output "vector_search_psc_ip" {
  value = module.network_connectivity.regional_psc_addresses["vector-index"].address
}

output "vector_search_psc_ip_self_link" {
  value = module.network_connectivity.regional_psc_addresses["vector-index"].self_link
}

output "translation_ilb_ip" {
  value = module.network_connectivity.reserved_internal_addresses["translation-ilb"].address
}

output "salesagent_ilb_ip" {
  value = module.network_connectivity.reserved_internal_addresses["salesagent-ilb"].address
}

output "frontend_ilb_ip" {
  value = module.network_connectivity.reserved_internal_addresses["frontend-ilb"].address
}
