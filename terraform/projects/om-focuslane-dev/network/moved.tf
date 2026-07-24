# State migration from pre-module layout to modular layout (om-focus-lane).

moved {
  from = google_compute_network.aicoe_network
  to   = module.network_base.google_compute_network.network
}

moved {
  from = google_compute_subnetwork.aicoe_subnet
  to   = module.network_base.google_compute_subnetwork.subnet
}

moved {
  from = google_compute_subnetwork.aicoe_proxy_only_subnet
  to   = module.network_base.google_compute_subnetwork.proxy_only_subnet
}

moved {
  from = google_compute_firewall.aicoe_egress_deny_all
  to   = module.network_base.google_compute_firewall.egress_deny_all[0]
}

moved {
  from = google_compute_firewall.aicoe_egress_allow_google_apis_psc
  to   = module.network_base.google_compute_firewall.egress_allow_google_apis_psc[0]
}

moved {
  from = google_compute_address.aicoe_staticip_ilb
  to   = module.network_connectivity.google_compute_address.reserved_internal_address["ilb"]
}

moved {
  from = google_compute_global_address.aicoe_psc_address
  to   = module.network_connectivity.google_compute_global_address.psc_google_apis_address[0]
}

moved {
  from = google_compute_global_forwarding_rule.aicoe_psc_google_apis
  to   = module.network_connectivity.google_compute_global_forwarding_rule.psc_google_apis[0]
}

# NOT moved (kept as plain resources - see comments in firewall.tf and
# cloud_dns.tf for why):
#   google_compute_firewall.aicoe_ingress_allow_https
#   google_dns_managed_zone.aicoe_googleapis_private
#   google_dns_record_set.aicoe_wildcard_googleapis
