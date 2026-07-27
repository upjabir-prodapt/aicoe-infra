###########################################
### Static Layer Remote TF State file   ###
###########################################

data "terraform_remote_state" "static" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    prefix = "tfstate-static"
  }
}

###########################################
### Network Layer Remote TF State file   ###
###########################################

data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    prefix = "tfstate-network"
  }
}
