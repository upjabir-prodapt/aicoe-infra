# ###########################################
# ###      AICOE subnet             ###
# ###########################################

# resource "google_compute_subnetwork" "aicoe_subnet" {
#   name          = "${var.project}-subnet"
#   region        = var.region
#   network       = google_compute_network.aicoe_network.self_link
#   ip_cidr_range = var.aicoe_subnet_cidr_range

#   private_ip_google_access = true

#   }
