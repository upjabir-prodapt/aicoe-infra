# resource "google_compute_address" "aicoe_staticip_vxaiwb" {
#   count  = var.envname == "sandox" ? 1 : 0
#   name         = "${var.project}${var.envname}-vxaiwb"
#   subnetwork   = google_compute_subnetwork.aicoe_subnet.id
#   address_type = "INTERNAL"
#   address      = var.aicoe_static_vxaiwb_ip
#   region       = var.region
#   labels = {
#     env    = "${var.envname}"
#     system = "${var.project}${var.envname}"
#   }
# }

# ################### IP address for Translation LB #################################
# resource "google_compute_address" "aicoe_staticip_ilb" {
#   name         = "${var.project}${var.envname}-ilb"
#   subnetwork   = google_compute_subnetwork.aicoe_subnet.id
#   address_type = "INTERNAL"
#   address      = var.aicoe_static_ilb_ip
#   region       = var.region
#   labels = {
#     env    = "${var.envname}"
#     system = "${var.project}${var.envname}"
#   }
# }

# #################### IP address for Sales-Agent LB #################################
# resource "google_compute_address" "aicoe_staticip_ilb_salesagent" {
#   name         = "${var.project}${var.envname}-ilb-salesagent"
#   subnetwork   = google_compute_subnetwork.aicoe_subnet.id
#   address_type = "INTERNAL"
#   address      = var.aicoe_static_ilb_salesagent_ip
#   region       = var.region
#   labels = {
#     env    = "${var.envname}"
#     system = "${var.project}${var.envname}"
#   }
# }