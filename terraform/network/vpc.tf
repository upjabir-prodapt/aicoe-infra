###########################################
###      AICOE VPC Network             ###
###########################################
resource "google_compute_network" "aicoe_network" {
  name                    = "${var.project}-vpc"
  auto_create_subnetworks = false
}
