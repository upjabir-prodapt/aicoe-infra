locals {
  gcp_project_id  = var.gcp_project_id != "" ? var.gcp_project_id : "${var.project}${var.envname}"
  resource_prefix = var.resource_prefix != "" ? var.resource_prefix : "${var.project}${var.envname}"
  state_bucket    = var.state_bucket != "" ? var.state_bucket : "${var.project}${var.envname}-bucket-tf-state"

  network_self_link  = data.terraform_remote_state.network.outputs.network_self_link
  subnet_self_link   = data.terraform_remote_state.network.outputs.subnet_self_link
  network_id         = data.terraform_remote_state.network.outputs.network_id
  translation_ilb_ip = data.terraform_remote_state.network.outputs.translation_ilb_ip
  salesagent_ilb_ip  = data.terraform_remote_state.network.outputs.salesagent_ilb_ip
  frontend_ilb_ip    = data.terraform_remote_state.network.outputs.frontend_ilb_ip

  default_labels = {
    environment = var.envname
    managed_by  = "terraform"
    project     = var.project_name
    team        = "ai-coe"
  }
}
