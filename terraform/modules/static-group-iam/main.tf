resource "google_project_iam_member" "group_members" {
  for_each = toset(var.roles)
  project  = var.gcp_project_id
  role     = each.value
  member   = "group:${var.group_email}"
}
