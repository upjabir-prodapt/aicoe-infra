resource "google_tags_tag_key" "env" {
    parent = "projects/${var.project}${var.envname}"
    short_name = "environment"
}

resource "google_tags_tag_value" "env" {
    parent = google_tags_tag_key.env.id
    short_name = var.envname
}

# Bind the value to the whole project.
resource "google_tags_tag_binding" "env_project" {
    parent = "//cloudresourcemanager.googleapis.com/projects/${var.project_number}"
    tag_value = google_tags_tag_value.env.id
}