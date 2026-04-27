###########################################
###     AICOE StaticIP-1 for Cloud NAT ###
###########################################
 
resource "google_compute_address" "aicoe_staticip_nat_1" {
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
  name   = "${var.project}${var.envname}-staticip-nat-2"
  region = var.region
  labels = {
    env    = "${var.envname}"
    system = "${var.project}${var.envname}"
  }
}