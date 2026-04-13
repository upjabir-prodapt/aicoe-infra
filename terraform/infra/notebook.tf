resource "google_notebooks_runtime" "aicoe_notebook_instance" {
  name     = "${var.project}${var.envname}-notebook"
  location = var.region
  project  = "${var.project}${var.envname}"

  software_config {
    post_startup_script = null
    install_gpu_driver  = true
  }

  virtual_machine {
    virtual_machine_config {
      machine_type = var.machine_type
      labels = {
            env    = var.envname
            system = "${var.project}${var.envname}"
  }
      metadata = {
        terraform                  = "true"
        notebook-disable-root      = "true"
        notebook-disable-downloads = "true"
        notebook-disable-nbconvert = "true"
        report-system-health       = "true"
      }
      network          = data.terraform_remote_state.network.outputs.aicoe_network_id
      subnet           = data.terraform_remote_state.network.outputs.aicoe_subnet_name
      internal_ip_only = true
      data_disk {
        initialize_params {
          disk_size_gb = var.data_disk_size_gb
          disk_type    = var.boot_disk_type
        }
      }
      accelerator_config {
        type       = var.gpu_type
        core_count = 1
      }
    }
  }
   lifecycle {
    prevent_destroy = false
  }

}
