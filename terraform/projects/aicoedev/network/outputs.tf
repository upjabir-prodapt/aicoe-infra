output "aicoe_network" {
  value = module.network_base.network_self_link
}
 
output "aicoe_network_id" {
  value = module.network_base.network_id
}
 
output "aicoe_subnet_name" {
  value = module.network_base.subnet_self_link
}
 
output "aicoe_proxy_only_subnet_name" {
  value = module.network_base.proxy_only_subnet_self_link
}
 
output "aicoe_staticip_ilb" {
  value = module.network_connectivity.reserved_internal_addresses["translation-ilb"].address
}
 
output "aicoe_subnet_cidr" {
  value = module.network_base.subnet_cidr_range
}
 
output "psc_endpoint_ip" {
  value = module.network_connectivity.psc_google_apis_ip
}
 
output "dns_zone_name" {
  value = module.network_connectivity.googleapis_dns_zone_name
}
 
output "aicoe_staticip_ilb_salesagent" {
  value = module.network_connectivity.reserved_internal_addresses["salesagent-ilb"].address
}
 
output "aicoe_staticip_ilb_aihub" {
  value = module.network_connectivity.reserved_internal_addresses["frontend-ilb"].address
}
 
# Kept for the infra layer's vector-search module, which now owns the PSC
# forwarding rule to the vector index (see infra/moved.tf note).
output "vector_search_psc_ip_self_link" {
  value = module.network_connectivity.regional_psc_addresses["vector-index"].self_link
}
 
 