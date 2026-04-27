###########################################
###      Create Router for Cloud NAT    ###
###########################################
 
resource "google_compute_router" "aicoe_router_cloudnat" {
  count   = var.envname == "sandox" ? 1 : 0
  project = "${var.project}${var.envname}"
  name    = "${var.project}${var.envname}-router-cloudnat"
  network = google_compute_network.aicoe_network.self_link
  region  = var.region
}
 
###########################################
###    Create Cloud NAT & Add to Router ###
###########################################
 
resource "google_compute_router_nat" "aicoe_cloudnat" {
  count                  = var.envname == "sandox" ? 1 : 0
  name                   = "${var.project}${var.envname}-cloudnat"
  router                 = google_compute_router.aicoe_router_cloudnat.name
  region                 = var.region
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = [
    google_compute_address.aicoe_staticip_nat_1.self_link,
    google_compute_address.aicoe_staticip_nat_2.self_link
  ]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
 
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}