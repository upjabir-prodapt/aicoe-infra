###########################################
###       Network and Subnets           ###
###########################################


output "aicoe_network" {
  value = google_compute_network.aicoe_network.self_link
}

output "aicoe_network_id" {
  value = google_compute_network.aicoe_network.id
}

output "aicoe_subnet_name" {
  value = google_compute_subnetwork.aicoe_subnet.self_link
}

output "aicoe_proxy_only_subnet_name" {
  value = google_compute_subnetwork.aicoe_proxy_only_subnet.self_link
}

output "aicoe_staticip_ilb" {
  value = google_compute_address.aicoe_staticip_ilb
}

output "aicoe_subnet_cidr" {
  value = var.aicoe_subnet_cidr_range
}

output "psc_endpoint_ip" {
  value       = google_compute_global_address.aicoe_psc_address.address
}

output "dns_zone_name" {
  value       = google_dns_managed_zone.aicoe_googleapis_private.name
}
