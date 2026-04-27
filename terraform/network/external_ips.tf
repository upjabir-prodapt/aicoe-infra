###########################################
###     AICOE StaticIP-1 for Cloud NAT ###
###########################################
 
resource "google_compute_address" "aicoe_staticip_nat_1" {
  count  = var.envname == "sandox" ? 1 : 0
  name   = "${var.project}${var.envname}-staticip-nat-1"
  region = var.region
  labels = {
    env    = "${var.envname}"
    system = "${var.project}${var.envname}"
  }
}
 
###########################################
###     AICOE StaticIP-2 for Cloud NAT ###
###########################################
 
resource "google_compute_address" "aicoe_staticip_nat_2" {
  count  = var.envname == "sandox" ? 1 : 0
  name   = "${var.project}${var.envname}-staticip-nat-2"
  region = var.region
  labels = {
    env    = "${var.envname}"
    system = "${var.project}${var.envname}"
  }
}