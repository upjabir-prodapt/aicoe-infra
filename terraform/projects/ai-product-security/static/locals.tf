locals {
  # NOTE: preserves the original flat-layer convention of hyphenating
  # project and envname (unlike aicoedev, which concatenates them with no
  # separator). Changing this would change the GCP project id Terraform
  # targets, so it must stay exactly as-is.
  gcp_project_id = "${var.project}-${var.envname}"
}
