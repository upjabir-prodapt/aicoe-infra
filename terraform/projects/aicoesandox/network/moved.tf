# State migration from pre-module layout to modular layout.

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
  from = google_compute_firewall.aicoe_ingress_allow_iap
  to   = module.network_base.google_compute_firewall.ingress_allow_iap[0]
}

moved {
  from = google_compute_firewall.aicoe_egress_allow_fastly_pypi
  to   = module.network_base.google_compute_firewall.egress_allow_fastly_pypi[0]
}

moved {
  from = google_compute_firewall.aicoe_ingress_allow_azure_devops
  to   = module.network_base.google_compute_firewall.ingress_allow_azure_devops[0]
}

moved {
  from = google_compute_firewall.aicoe_egress_allow_azure_devops
  to   = module.network_base.google_compute_firewall.egress_allow_azure_devops[0]
}

moved {
  from = google_compute_firewall.aicoe_ingress_allow_https
  to   = module.network_base.google_compute_firewall.ingress_allow_https[0]
}

moved {
  from = google_compute_firewall.aicoe_allow_internal_ilb
  to   = module.network_base.google_compute_firewall.allow_internal_ilb[0]
}

moved {
  from = google_compute_firewall.aicoe_egress_allow_google_apis_psc
  to   = module.network_base.google_compute_firewall.egress_allow_google_apis_psc[0]
}

moved {
  from = google_compute_address.aicoe_staticip_nat_1
  to   = module.network_connectivity.google_compute_address.nat_ip["staticip-nat-1"]
}

moved {
  from = google_compute_address.aicoe_staticip_nat_2
  to   = module.network_connectivity.google_compute_address.nat_ip["staticip-nat-2"]
}

moved {
  from = google_compute_router.aicoe_router_cloudnat
  to   = module.network_connectivity.google_compute_router.cloud_nat_router[0]
}

moved {
  from = google_compute_router_nat.aicoe_cloudnat
  to   = module.network_connectivity.google_compute_router_nat.cloud_nat[0]
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
  from = google_dns_managed_zone.aicoe_googleapis_private
  to   = module.network_connectivity.google_dns_managed_zone.googleapis_private[0]
}

moved {
  from = google_dns_record_set.aicoe_wildcard_googleapis
  to   = module.network_connectivity.google_dns_record_set.wildcard_googleapis[0]
}

moved {
  from = google_dns_managed_zone.aicoe_internal
  to   = module.network_connectivity.google_dns_managed_zone.internal[0]
}

moved {
  from = google_dns_managed_zone.aicoe_googleusercontent_private
  to   = module.network_connectivity.google_dns_managed_zone.googleusercontent_private[0]
}

moved {
  from = google_dns_record_set.aicoe_wildcard_googleusercontent
  to   = module.network_connectivity.google_dns_record_set.wildcard_googleusercontent[0]
}

moved {
  from = google_compute_address.aicoe_staticip_vxaiwb
  to   = module.network_connectivity.google_compute_address.reserved_internal_address["workbench"]
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
  from = google_compute_address.aicoe_staticip_ilb_frontend
  to   = module.network_connectivity.google_compute_address.reserved_internal_address["frontend-ilb"]
}

moved {
  from = google_dns_record_set.aicoe_translation_dns
  to   = module.network_connectivity.google_dns_record_set.internal_records["translation"]
}

moved {
  from = google_dns_record_set.aicoe_salesagent_dns
  to   = module.network_connectivity.google_dns_record_set.internal_records["salesagent"]
}

moved {
  from = google_dns_record_set.aicoe_aihub
  to   = module.network_connectivity.google_dns_record_set.internal_records["aihub"]
}
