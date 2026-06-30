output "network_self_link" {
  value = google_compute_network.network.self_link
}

output "network_id" {
  value = google_compute_network.network.id
}

output "subnet_self_link" {
  value = google_compute_subnetwork.subnet.self_link
}

output "subnet_id" {
  value = google_compute_subnetwork.subnet.id
}

output "proxy_only_subnet_self_link" {
  value = google_compute_subnetwork.proxy_only_subnet.self_link
}

output "subnet_cidr_range" {
  value = var.subnet_cidr_range
}
