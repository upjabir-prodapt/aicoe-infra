/*
resource "google_compute_address" "aicoe_staticip_vxaiwb" {
  count  = var.envname == "sandox" ? 1 : 0
  name         = "${var.project}-vxaiwb-vegadev"
  subnetwork   = google_compute_subnetwork.aicoe_subnet.id
  address_type = "INTERNAL"
  address      = var.aicoe_static_vxaiwb_ip
  region       = var.region
  labels = {
    env    = "${var.envname}"
    system = "${var.project}${var.envname}"
  }
}
*/