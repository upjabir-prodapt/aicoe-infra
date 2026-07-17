resource "google_privileged_access_manager_entitlement" "pam" {
  entitlement_id       = var.entitlement_id
  location             = "global"                 # PAM entitlements are global
  parent               = "projects/${var.gcp_project_id}"
  max_request_duration = var.max_request_duration  # e.g. "3600s" = 1 hour
 
  # Requester must give a justification
  requester_justification_config {
    unstructured {}
  }
 
  # WHO can request
  eligible_users {
    principals = var.requester_principals          # e.g. ["group:aicoe-dev-oncall@colt.net"]
  }
 
  # # WHAT they get, and on which resource
  privileged_access {
    gcp_iam_access {
      resource      = "//cloudresourcemanager.googleapis.com/projects/${var.gcp_project_id}"
      resource_type = "cloudresourcemanager.googleapis.com/Project"
 
      dynamic "role_bindings" {
        for_each = var.elevated_roles
        content {
          role = role_bindings.value               # e.g. "roles/bigquery.admin"
        }
      }
    }
  }
 
  # WHETHER approval is needed (omit this block entirely for auto-grant)
  dynamic "approval_workflow" {
    for_each = var.require_approval ? ["enabled"] : []
    content {
    manual_approvals {
      require_approver_justification = true
      steps {
        approvals_needed = 1                        # currently only 1 is supported
        approvers {
          principals = var.approver_principals       # e.g. ["group:aicoe-platform-leads@colt.net"]
        }
      }
    }
  }
}
}