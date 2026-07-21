locals {
  gcp_project_id  = var.gcp_project_id != "" ? var.gcp_project_id : "${var.project}${var.envname}"
  resource_prefix = var.resource_prefix != "" ? var.resource_prefix : "${var.project}${var.envname}"
  state_bucket    = var.state_bucket != "" ? var.state_bucket : "${var.project}${var.envname}-bucket-tf-state"

  network_self_link  = data.terraform_remote_state.network.outputs.aicoe_network
  subnet_self_link   = data.terraform_remote_state.network.outputs.aicoe_subnet_name
  network_id         = data.terraform_remote_state.network.outputs.aicoe_network_id
  salesagent_ilb_ip  = data.terraform_remote_state.network.outputs.aicoe_staticip_ilb_salesagent
  frontend_ilb_ip    = data.terraform_remote_state.network.outputs.aicoe_staticip_ilb_aihub

  # Same rationale as the other layers - keep dev's existing label shape.
  default_labels = {
    env    = var.envname
    system = local.resource_prefix
  }

}
 