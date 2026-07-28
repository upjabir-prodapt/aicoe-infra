######moved {
######  from = google_compute_network.aicoe_network
######  to   = module.network_base.google_compute_network.network
######}
######
####### State currently sits at the unindexed module address (from an earlier apply,
####### before count was added to this resource) - chain it on to the indexed address
####### the count-based config now expects.
######moved {
######  from = module.network_base.google_compute_subnetwork.subnet
######  to   = module.network_base.google_compute_subnetwork.subnet[0]
######}
######
######moved {
######  from = module.network_base.google_compute_subnetwork.proxy_only_subnet
######  to   = module.network_base.google_compute_subnetwork.proxy_only_subnet[0]
######}
######
######moved {
######  from = google_compute_firewall.aicoe_egress_deny_all
######  to   = module.network_base.google_compute_firewall.egress_deny_all[0]
######}
######
####### NOTE: not routed through network_base (enable_google_apis_psc_egress = false) -
####### the module hardcodes a single allow{tcp,443} block, but the real dev resource
####### also has a second allow{tcp,10000} block the module can't reproduce. State
####### currently sits inside the module (from the original migration) - chain it
####### out to the plain resource defined below.
######moved {
######  from = module.network_base.google_compute_firewall.egress_allow_google_apis_psc[0]
######  to   = google_compute_firewall.aicoe_egress_allow_google_apis_psc
######}
######
######moved {
######  from = google_compute_global_address.aicoe_psc_address
######  to   = module.network_connectivity.google_compute_global_address.psc_google_apis_address[0]
######}
######
######moved {
######  from = google_compute_global_forwarding_rule.aicoe_psc_google_apis
######  to   = module.network_connectivity.google_compute_global_forwarding_rule.psc_google_apis[0]
######}
######
######moved {
######  from = google_compute_address.aicoe_psc_vector_index_ip
######  to   = module.network_connectivity.google_compute_address.regional_psc_address["vector-index"]
######}
######
######moved {
######  from = google_compute_address.aicoe_staticip_ilb
######  to   = module.network_connectivity.google_compute_address.reserved_internal_address["translation-ilb"]
######}
######
######moved {
######  from = google_compute_address.aicoe_staticip_ilb_salesagent
######  to   = module.network_connectivity.google_compute_address.reserved_internal_address["salesagent-ilb"]
######}
######
######moved {
######  from = google_compute_address.aicoe_staticip_ilb_aihub
######  to   = module.network_connectivity.google_compute_address.reserved_internal_address["frontend-ilb"]
######}
######
###### 


moved {
  from = google_compute_network.aicoe_network
  to   = module.network_base.google_compute_network.network
}

# State currently sits at the unindexed module address (from an earlier apply,
# before count was added to this resource) - chain it on to the indexed address
# the count-based config now expects.
moved {
  from = module.network_base.google_compute_subnetwork.subnet
  to   = module.network_base.google_compute_subnetwork.subnet[0]
}

moved {
  from = module.network_base.google_compute_subnetwork.proxy_only_subnet
  to   = module.network_base.google_compute_subnetwork.proxy_only_subnet[0]
}

moved {
  from = google_compute_firewall.aicoe_egress_deny_all
  to   = module.network_base.google_compute_firewall.egress_deny_all[0]
}

moved {
  from = google_compute_firewall.aicoe_ingress_allow_https
  to   = module.network_base.google_compute_firewall.ingress_allow_https[0]
}

moved {
  from = google_compute_firewall.aicoe_ingress_allow_iap
  to   = module.network_base.google_compute_firewall.ingress_allow_iap[0]
}

moved {
  from = google_compute_global_address.aicoe_psc_address
  to   = module.network_connectivity.google_compute_global_address.psc_google_apis_address[0]
}

moved {
  from = google_compute_global_forwarding_rule.aicoe_psc_google_apis
  to   = module.network_connectivity.google_compute_global_forwarding_rule.psc_google_apis[0]
}

moved {
  from = google_compute_address.aicoe_psc_vector_index_ip
  to   = module.network_connectivity.google_compute_address.regional_psc_address["vector-index"]
}

moved {
  from = google_compute_address.aicoe_staticip_ilb
  to   = module.network_connectivity.google_compute_address.reserved_internal_address["translation-ilb"]
}

moved {
  from = google_compute_address.aicoe_staticip_ilb_salesagent
  to   = module.network_connectivity.google_compute_address.reserved_internal_address["salesagent-ilb"]
}

moved {
  from = google_compute_address.aicoe_staticip_ilb_aihub
  to   = module.network_connectivity.google_compute_address.reserved_internal_address["frontend-ilb"]
}

 