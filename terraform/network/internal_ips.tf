resource "google_compute_address" "aicoe_staticip_vxaiwb" {
  name         = "${var.project}${var.envname}-vxaiwb"
  subnetwork   = google_compute_subnetwork.aicoe_subnet.id
  address_type = "INTERNAL"
  address      = var.aicoe_static_vxaiwb_ip
  region       = var.region
  labels = {
    env    = "${var.envname}"
    system = "${var.project}${var.envname}"
  }
}

#################### IP address for LB #################################
resource "google_compute_address" "aicoe_staticip_ilb" {
  name         = "${var.project}${var.envname}-ilb"
  subnetwork   = google_compute_subnetwork.aicoe_subnet.id
  address_type = "INTERNAL"
  address      = var.aicoe_static_ilb_ip
  region       = var.region
  labels = {
    env    = "${var.envname}"
    system = "${var.project}${var.envname}"
  }
}