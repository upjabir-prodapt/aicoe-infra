# resource "google_project_iam_member" "aicoe_group" {
#     for_each = toset([
#         "roles/viewer",
#         "roles/aiplatform.user",
#     ])
#     project = "${var.project}"
#     role = each.value
#     member = "group:gcp-aicoeaiworkshop-users@colt.net"
# }