###########################################
###       Network and Subnets           ###
###########################################

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
  value = module.network_connectivity.reserved_internal_addresses["ilb"].address
}

output "aicoe_subnet_cidr" {
  value = module.network_base.subnet_cidr_range
}

output "psc_endpoint_ip" {
  value = google_compute_global_address.aicoe_psc_address.address
}

output "dns_zone_name" {
  value = google_dns_managed_zone.aicoe_googleapis_private.name
}
