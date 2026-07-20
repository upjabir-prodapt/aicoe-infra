###########################################
### Static Layer Remote TF State file   ###
###########################################

data "terraform_remote_state" "static" {
  backend = "gcs"
  config = {
    bucket = "vegadev-bucket-tf-state"
    prefix = "tfstate-static"
  }
}

###########################################
### Infra Layer Remote TF State file   ###
###########################################

data "terraform_remote_state" "infra" {
  backend = "gcs"
  config = {
    bucket = "vegadev-bucket-tf-state"
    prefix = "tfstate-infra"
  }
}
