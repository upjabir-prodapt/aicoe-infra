# -----------------------------------------------------------------------------
# Firewall Rules - DENY ALL
# -----------------------------------------------------------------------------

resource "google_compute_firewall" "aicoe_egress_deny_all" {
    name                    = "egress-deny-all"
    network                 = google_compute_network.aicoe_network.id
    description             = "Blanket default deny rule for egress"
    direction               = "EGRESS"
    priority                = 65535
    destination_ranges      = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    deny  {
        protocol = "all"
        ports    = null # All ports
    }
    log_config  {
        metadata = "INCLUDE_ALL_METADATA"
    }
}

# -----------------------------------------------------------------------------
# Firewall Rules - IAP SSH
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "aicoe_ingress_allow_iap" {
  count  = var.envname == "sandox" ? 1 : 0
  name                    = "ingress-allow-iap-ssh"
  network                 = google_compute_network.aicoe_network.id
  description             = "FW rules required to ssh into instances via IAP - useful for diagnosing faulty notebooks/instances"
  direction               = "INGRESS"
  source_tags             = null
  source_service_accounts = null
  target_tags             = null
  target_service_accounts = null
  priority                = 65534

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}
# -----------------------------------------------------------------------------
# Firewall Rules - ALLOW FASTLY PYPI
# -----------------------------------------------------------------------------

resource "google_compute_firewall" "aicoe_egress_allow_fastly_pypi" {
      count  = var.envname == "sandox" ? 1 : 0
      name                    = "egress-allow-fastly-cdn-for-pypi"
      network                 = google_compute_network.aicoe_network.id
      description             = "Allow egress from instances in this network to the Fastly CDN IP Ranges, which is used by PyPi"
      direction               = "EGRESS"
      priority                = 65534
      destination_ranges      = ["23.235.32.0/20", "43.249.72.0/22", "103.244.50.0/24", "103.245.222.0/23", "103.245.224.0/24", "104.156.80.0/20", "140.248.64.0/18", "140.248.128.0/17", "146.75.0.0/17", "151.101.0.0/16", "157.52.64.0/18", "167.82.0.0/17", "167.82.128.0/20", "167.82.160.0/20", "167.82.224.0/20", "172.111.64.0/18", "185.31.16.0/22", "199.27.72.0/21", "199.232.0.0/16"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow {
        protocol = "tcp"
        ports    = ["443", "3128"]
      }
      
      log_config {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }

# -----------------------------------------------------------------------------
# Firewall Rules - INGRESS ALLOW AZURE DEVOPS
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "aicoe_ingress_allow_azure_devops" {
      count  = var.envname == "sandox" ? 1 : 0
      name        = "ingress-allow-tcp-azure-devops"
      network     = google_compute_network.aicoe_network.id
      description = "To allow inbound connection from Azure DevOps outbound IP ranges - Ingress"
      direction   = "INGRESS"
      priority    = 65534
      source_ranges = [
        # Azure DevOps outbound ranges (IPv4)
        "150.171.22.0/24",
        "150.171.23.0/24",
        "150.171.73.0/24",
        "150.171.74.0/24",
        "150.171.75.0/24",
        "150.171.76.0/24",
        # Legacy IPs - keep per Microsoft guidance
        "13.107.6.183/32",
        "13.107.9.183/32"
        
      ]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow {
        protocol = "tcp"
        ports    = ["22", "443"]
      }
      
      
      log_config  {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }

# -----------------------------------------------------------------------------
# Firewall Rules - EGRESS ALLOW AZURE DEVOPS
# -----------------------------------------------------------------------------
    
resource "google_compute_firewall" "aicoe_egress_allow_azure_devops" {
      count  = var.envname == "sandox" ? 1 : 0
      name        = "egress-allow-tcp-azure-devops"
      network     = google_compute_network.aicoe_network.id
      description = "To allow outbound connection to Azure DevOps IP ranges - Egress"
      direction   = "EGRESS"
      priority    = 65534
      destination_ranges = [
        # Azure DevOps outbound ranges (IPv4)
        "150.171.22.0/24",
        "150.171.23.0/24",
        "150.171.73.0/24",
        "150.171.74.0/24",
        "150.171.75.0/24",
        "150.171.76.0/24",
        # Legacy IPs - keep per Microsoft guidance
        "13.107.6.183/32",
        "13.107.9.183/32"
        
      ]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow {
        protocol = "tcp"
        # 443 for HTTPS, 22 for SSH git operations
        ports    = ["22", "443"]
      }
   
      log_config  {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }
  
#Allow HTTPS port 443 for ILB
resource "google_compute_firewall" "aicoe_ingress_allow_https" {
      name        = "ingress-allow-https-ilb"
      network     = google_compute_network.aicoe_network.id
      description = "Allow HTTPS traffic for Internal Load Balancer - Ingress"
      direction   = "INGRESS"
      priority    = 65534
      source_ranges = [
       "10.110.74.0/24",
       "130.211.0.0/22",                 #Google cloud load balancer IPs
       "35.191.0.0/16"                   #Google cloud health checker IPs
      ]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow {
        protocol = "tcp"
        ports    = ["443"]
      }
      
      
      log_config  {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }