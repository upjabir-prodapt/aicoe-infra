project_name             = "aicoedev"
project                  = "aicoe"
envname                  = "dev"
region                   = "europe-west1"
cloud_run_service_name   = "translation-api-service"
cloud_run_service_name2  = "sales-research-application"
cloud_run_service_name3  = "translation-ui-service"

# dev has no notebook today; leave these unset (module "notebook" isn't
# called in main.tf). Fill these in if/when you add it.
# machine_type      = "e2-standard-4"
# boot_disk_size_gb = 150
# boot_disk_type    = "PD_BALANCED"
# data_disk_size_gb = 100
# data_disk_type    = "PD_BALANCED"
 