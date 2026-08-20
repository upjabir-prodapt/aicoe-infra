# Technical Context

## Core Technologies & Tooling
- **Terraform 1.9.8:** Configured locally with GCS remote backends. Matches CI environment.
- **Google & Google-Beta Provider v6.50.0:** Standard providers for GCP resource management.
- **gcloud CLI:** For workspace authentication, service configurations, and live inspection.
- **jq:** Standard CLI tool used for parsing and converting Stage-to-Stage handoffs.

## Technical Constraints & Guardrails
- **`prevent_destroy`:** Active on state buckets, KMS keys, the main public load balancer VIP `10.110.73.20`, and Certificate Manager keys.
- **CMEK Enforced:** All storage buckets, datasets, and secret managers must have CMEK protection. No default Google-managed keys on these resources (except Firestore for now due to Google-gate allowlist limits).
- **VPC Service Controls:** Egress is strictly blocked. Only designated PSC targets are whitelisted via firewall rules.
- **No remote state read:** Stages only consume output values that are passed via `.auto.tfvars.json` files loaded automatically by Terraform.

## Workspace & Directory Structure
- Root: `/home/jabir_mohammed_colt_net/AICOE-Terraform`
- Configuration stages: `terraform/<stage_number>-<stage_name>/`
- Centralized handoffs directory: `terraform/vars-handoff/` (contains stage outputs as `<stage>.auto.tfvars.json`)
- Shared tfvars: `terraform/envs/dev/terraform.tfvars`
- Stage-specific tfvars (local convenience): `terraform/envs/dev/stages/<stage_name>.tfvars`

## Regional Alignment & Production Plan (Frankfurt Unified)
- **Primary Hosting Region:** `europe-west3` (Frankfurt) is the standard region for all platform workloads, VPC subnets, and Customer-Managed Encryption Keys (CMEK).
- **Production Standard:** For the upcoming Greenfield Production Environment (`prod`), the platform's primary `region` and the Apigee `analytics_region` must both be unified to **`europe-west3`** (Frankfurt).
  - Since `europe-west3` fully supports both Apigee Runtimes, API Analytics, and API Hub natively, this removes any cross-region dependencies (like the legacy `europe-west2` analytics region used in Dev due to the immutability of the existing Dev Apigee organization).
