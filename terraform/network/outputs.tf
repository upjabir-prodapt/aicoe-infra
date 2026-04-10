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
  value = google_compute_subnetwork.aicoe_subnet.name
}

output "aicoe_subnet_cidr" {
  value = var.aicoe_subnet_cidr_range
}

