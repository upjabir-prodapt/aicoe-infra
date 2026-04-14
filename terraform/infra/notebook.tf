resource "google_workbench_instance" "aicoe_vertex_ai_workbench" {

  name        = "${var.project}${var.envname}-notebook"
  location    = "${var.region}-b"
  project     = "${var.project}${var.envname}"
  instance_id = "${var.project}${var.envname}-notebook"
  

  gce_setup {
    machine_type         = var.machine_type
    disable_public_ip    = true

     network_interfaces {  
    network          = data.terraform_remote_state.network.outputs.aicoe_network
    subnet           = data.terraform_remote_state.network.outputs.aicoe_subnet_name
    }
    
    boot_disk {
      disk_size_gb    = var.boot_disk_size_gb
      disk_type       = var.boot_disk_type   
      
    }
         
    data_disks {
          disk_size_gb = var.data_disk_size_gb
          disk_type    = var.data_disk_type    
        }
    }
    
    labels = {
      env    = var.envname
      system = "${var.project}${var.envname}"
    }

    timeouts {
      create = "15m"
      delete = "15m"
    }
      
  }

  

