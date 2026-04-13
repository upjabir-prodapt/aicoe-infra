resource "google_workbench_instance" "vertex_ai_workbench" {

  name        = "${var.project}${var.envname}-notebook"
  location    = var.region
  project     = "${var.project}${var.envname}"
  instance_id = "${var.project}${var.envname}-notebook"
  

  gce_setup {
    machine_type         = var.machine_type
    disable_public_ip    = true
  

  network_interfaces {  # Explicit network and subnet
    network          = data.terraform_remote_state.network.outputs.aicoe_network_id
    subnet           = data.terraform_remote_state.network.outputs.aicoe_subnet_name
  }
    # Boot disk
    boot_disk {
      disk_size_gb    = var.boot_disk_size_gb
      disk_type       = var.boot_disk_type   # e.g. "PD_BALANCED"
      
    }
         
    data_disk {
        initialize_params {
          disk_size_gb = var.data_disk_size_gb
          disk_type    = var.data_disk_type    # e.g. "PD_SSD"
        }
      }

    # GPU accelerator
    accelerator {
      type       = var.gpu_type              # e.g. "NVIDIA_L4"
      core_count = 1
    }

   
  }

  lifecycle {
    prevent_destroy = false
  }
 
}
