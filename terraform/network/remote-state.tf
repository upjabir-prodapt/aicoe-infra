###########################################
### Static Layer Remote TF State file   ###
###########################################

data "terraform_remote_state" "static" {
  backend = "gcs"
  config = {
    bucket = "${var.prject}${var.envname}-bucket-tf-state"
    prefix = "tfstate-static"
  }
}
