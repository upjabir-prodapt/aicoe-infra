# PSC address + forwarding rule for Google APIs now come from
# module.network_connectivity (enable_psc = true in main.tf).
#
# They used to be plain resources here because the module's forwarding
# rule name was hardcoded to replace(resource_prefix, "-", "") + "pscapis",
# which for om-focus-lane would be "omfocuslanedevpscapis" (22 chars) -
# both a different name than the existing "omfocuslanepscapis" AND over
# GCP's 20-character limit for all-apis-bundle PSC forwarding rule names.
# modules/network-connectivity now accepts a
# psc_google_apis_forwarding_rule_name override, so the module can be used
# with the legacy name pinned. See main.tf and moved.tf.
