output "aicoe_staticip_ilb" {
  value = try(google_compute_address.aicoe_staticip_ilb[0].address, null)
}

output "aicoe_staticip_ilb_salesagent" {
  value = try(google_compute_address.aicoe_staticip_ilb_salesagent[0].address, null)
}

output "aicoe_static_ilb_frontend_ip" {
  value       = try(google_compute_address.aicoe_staticip_ilb_frontend[0].address, null)
  description = "Internal IP for Frontend service ILB"
}

output "psc_endpoint_ip" {
  value = try(google_compute_global_address.aicoe_psc_address[0].address, null)
}

output "dns_zone_name" {
  value = try(google_dns_managed_zone.aicoe_googleapis_private[0].name, null)
}

output "vector_search_psc_ip" {
  value       = try(google_compute_address.aicoe_psc_vector_index_ip[0].address, null)
  description = "Internal IP for PSC access to the vector index endpoint"
}

output "vector_search_psc_ip_self_link" {
  value       = try(google_compute_address.aicoe_psc_vector_index_ip[0].self_link, null)
  description = "Self link for the vector search PSC reserved IP"
}
