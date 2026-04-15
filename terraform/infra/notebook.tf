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
    
    metadata = {
        "enable-oslogin"               = "FALSE"
        "serial-port-enable"           = "FALSE"
        "notebook-disable-root"        = "true"
        "notebook-disable-nbconvert"   = "true"
        "notebook-disable-downloads"   = "false"
        "notebook-disable-terminal"    = "false"
    }

    shielded_instance_config {
      enable_vtpm = true
      enable_secure_boot = true
      enable_integrity_monitoring = true
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

  

