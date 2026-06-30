output "reserved_internal_addresses" {
  value = {
    for key, address in google_compute_address.reserved_internal_address : key => {
      address   = address.address
      self_link = address.self_link
      id        = address.id
    }
  }
  description = "Regional internal IP reservations keyed by project-owned names"
}

output "regional_psc_addresses" {
  value = {
    for key, address in google_compute_address.regional_psc_address : key => {
      address   = address.address
      self_link = address.self_link
      id        = address.id
    }
  }
  description = "Regional PSC endpoint IP reservations keyed by project-owned names"
}

output "psc_google_apis_ip" {
  value = try(google_compute_global_address.psc_google_apis_address[0].address, null)
}

output "googleapis_dns_zone_name" {
  value = try(google_dns_managed_zone.googleapis_private[0].name, null)
}

output "internal_dns_zone_name" {
  value = try(google_dns_managed_zone.internal[0].name, null)
}
