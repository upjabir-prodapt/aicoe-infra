###########################################
### Static Layer Remote TF State file   ###
###########################################
# NOTE: prefixes kept exactly as in the flat layout ("tfstate-static"/
# "tfstate-network", no project-name subfolder) - see the same note in
# ../network/main.tf.

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

###data "terraform_remote_state" "network" {
###  backend = "gcs"
###  config = {
###    bucket = local.state_bucket
###    prefix = "tfstate-network"
###  }
###}

# NOTE: no infra-firestore module exists in ../../../modules yet, so
# google_firestore_database stays as a plain resource - see firestore.tf.
# This layer has no ILB, vector search, BigQuery, or notebook resources
# today (unlike ai-cmo-dev), so there's nothing else to modularize here.
