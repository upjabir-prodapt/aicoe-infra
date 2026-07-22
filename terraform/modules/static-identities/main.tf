resource "google_service_account" "sa" {
  for_each = var.service_accounts

  account_id   = each.value.account_id
  display_name = each.value.display_name
  project      = var.gcp_project_id
}

locals {
  iam_bindings = merge([
    for sa_key, sa in var.service_accounts : {
      for role in sa.roles : "${sa_key}-${role}" => {
        role       = role
        member_key = coalesce(sa.grant_roles_to_account_key, sa_key)
      }
    }
  ]...)
}

resource "google_project_iam_member" "iam" {
  for_each = local.iam_bindings

  project = var.gcp_project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.this[each.value.member_key].email}"
}
