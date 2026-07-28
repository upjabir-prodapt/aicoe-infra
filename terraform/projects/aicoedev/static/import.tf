# import {
#     to = module.group_iam["Aicoedev-platformadmin@colt.net"].google_project_iam_member.group_members["roles/compute.osAdminLogin"]
#     id = "aicoedev roles/compute.osAdminLogin group:Aicoedev-platformadmin@colt.net"
# }

# import {
#     to = module.group_iam["Aicoedev-platformadmin@colt.net"].google_project_iam_member.group_members["roles/iap.httpsResourceAccessor"]
#     id = "aicoedev roles/iap.httpsResourceAccessor group:Aicoedev-platformadmin@colt.net"
# }

# import {
#     to = module.group_iam["Aicoedev-platformadmin@colt.net"].google_project_iam_member.group_members["roles/owner"]
#     id = "aicoedev roles/owner group:Aicoedev-platformadmin@colt.net"
# }

# import {
#     to = module.group_iam["Aicoedev-platformadmin@colt.net"].google_project_iam_member.group_members["roles/iap.admin"]
#     id = "aicoedev roles/iap.admin group:Aicoedev-platformadmin@colt.net"
# }

import {
    to = module.identities.google_service_account.sa["ui"]
    id = "projects/aicoedev/serviceAccounts/aicoedev-ui-sa@aicoedev.iam.gserviceaccount.com"
}

import {
    to = module.identities.google_service_account.sa["app"]
    id = "projects/aicoedev/serviceAccounts/aicoedev-app-sa@aicoedev.iam.gserviceaccount.com"
}
