################### IP address for Cloud run application LB #################################
resource "google_compute_address" "aicoe_staticip_ilb" {
  name         = "${var.project}-${var.envname}-ilb"
  subnetwork   = google_compute_subnetwork.aicoe_subnet.id
  address_type = "INTERNAL"
  address      = var.aicoe_static_ilb_ip
  region       = var.region
  labels = {
    env    = "${var.envname}"
    system = "${var.project}-${var.envname}"
  }
}
