locals {
  common_labels = {
    env        = var.envname
    system     = "${var.project}${var.envname}"
    managed_by = "terraform"
    team       = "aicoe"
  }
}