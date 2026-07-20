moved {
  from = google_project_service.service
  to   = module.base.google_project_service.service
}

moved {
  from = google_project_iam_audit_config.data_access
  to   = module.base.google_project_iam_audit_config.data_access
}

moved {
  from = google_tags_tag_key.env
  to   = module.base.google_tags_tag_key.env
}

moved {
  from = google_tags_tag_value.env
  to   = module.base.google_tags_tag_value.env
}

moved {
  from = google_tags_tag_binding.env_project
  to   = module.base.google_tags_tag_binding.env_project
}
