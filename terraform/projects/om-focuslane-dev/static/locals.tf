locals {
  # om-focus-lane runs dev/sandox as environments inside a single GCP
  # project (unlike aicoedev, which uses one GCP project per environment),
  # so the GCP project id is just var.project - it must NOT have envname
  # appended to it.
  gcp_project_id = var.project

  # All existing om-focus-lane resource names follow the
  # "<project>-<envname>-..." pattern (with a hyphen), e.g.
  # "om-focus-lane-dev-vpc", "om-focus-lane-dev-app-sa". resource_prefix
  # reproduces that exactly so every module-generated name matches what's
  # already in state.
  resource_prefix = "${var.project}-${var.envname}"

  default_labels = {
    env    = var.envname
    system = var.project
  }
}
