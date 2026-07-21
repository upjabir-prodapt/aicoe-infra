output "network_self_link" {
  value = google_compute_network.network.self_link
}

output "network_id" {
  value = google_compute_network.network.id
}

output "subnet_self_link" {
  value = try(google_compute_subnetwork.subnet[0].self_link, null)
}

output "subnet_id" {
  value = try(google_compute_subnetwork.subnet[0].id, null)
}

output "proxy_only_subnet_self_link" {
  value = try(google_compute_subnetwork.proxy_only_subnet[0].self_link, null)
}

output "subnet_cidr_range" {
  value = var.subnet_cidr_range
}
 