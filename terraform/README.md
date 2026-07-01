# AICOE Terraform Layout

## Structure

```
terraform/
├── modules/           # Shared, generic reusable modules
└── projects/          # One folder per GCP project/workload
    └── <project>/
        ├── static/    # Optional layer
        ├── network/   # Optional layer
        └── infra/     # Optional layer
```

## Branches

| Branch | Environment | Projects |
|--------|-------------|----------|
| `main` / `sandbox-v1` | sandbox | aicoesandox, ai-research, pricing-agent, svcmgmtops, aicoeaiworkshop |

## State isolation

Each project layer uses its own GCS state prefix:

`{project_name}/tfstate-{static|network|infra}`

| Project | State bucket | `make` defaults |
|---------|--------------|-----------------|
| aicoesandox | `aicoesandox-bucket-tf-state` | `ENVNAME=sandox`, `PROJECT=aicoe` |
| ai-research | `ai-research-sandbox-bucket-tf-state` | `ENVNAME=sandbox` |
| pricing-agent | `pricingagent-sandbox-bucket-tf-state` | `ENVNAME=sandbox`, `PROJECT=pricingagent` |
| svcmgmtops | `svcmgmtops-sandbox-bucket-tf-state` | `ENVNAME=sandbox` |
| aicoeaiworkshop | `aicoeaiworkshopsandox-bucket-tf-state` | GCP project `aicoeaiworkshop`; `ENVNAME=sandox` for bucket/tag only |

Set `state_bucket` in `params.tfvars` when the GCP bucket name does not match `${project}${envname}-bucket-tf-state`.

If you renamed a project folder (e.g. `aicoe-core` → `aicoesandox`), copy or migrate existing state objects in GCS from the old prefix to the new one before the first apply, or Terraform will treat resources as new.

## Usage

### Prerequisites

- **Terraform** `1.15.7` (see repo-root `.terraform-version`)
- **Google providers** `7.39.0` (pinned in each layer's `.terraform.lock.hcl`)
- GCP credentials with access to the target project and state bucket

Install Terraform locally (with corporate proxy if required):

```bash
export https_proxy="${HTTPS_PROXY:-$HTTP_PROXY}"
curl -fsSL ${https_proxy:+-x "$https_proxy"} \
  "https://releases.hashicorp.com/terraform/1.15.7/terraform_1.15.7_linux_amd64.zip" \
  -o /tmp/terraform.zip
unzip -o /tmp/terraform.zip -d ~/.local/bin
terraform version
```

GitLab CI installs Terraform automatically in `before_script` via `.gitlab/ci/install-terraform.sh`, using `HTTP_PROXY` / `HTTPS_PROXY` GitLab CI/CD variables.

| Variable | Example |
|----------|---------|
| `HTTP_PROXY` | `http://proxy.example:8080` |
| `HTTPS_PROXY` | `http://proxy.example:8080` |

```bash
cd terraform/projects/aicoesandox/static
make plan ENVNAME=sandox
make apply ENVNAME=sandox
```

`aicoesandox` is the sandbox GCP project (`aicoesandox`) — sandbox branch only.

### Shared modules vs project-owned configuration

**`terraform/modules/`** holds generic, reusable building blocks. Modules accept maps and variables for anything that differs per project (names, IPs, roles, schemas, service lists, bucket suffixes, DNS records, and feature flags). They must not hardcode project-specific values, application names, private CIDRs, DNS hostnames, or service account role choices.

| Module | Purpose |
|--------|---------|
| `static-base` | APIs, audit config, environment tag binding |
| `static-storage` | Map/list-driven GCS buckets and KMS keys |
| `static-group-iam` | Group-based IAM bindings |
| `static-artifact` | Artifact Registry repository and optional project-owned bucket IAM bindings |
| `static-identities` | Map-driven service accounts and project IAM roles |
| `network-base` | VPC, subnets, project-supplied CIDR/range inputs, optional firewall rule sets |
| `network-connectivity` | NAT, PSC, map-driven reserved IPs, internal DNS |
| `infra-notebook` | Vertex AI Workbench instance |
| `infra-serverless-ilb` | Map-driven internal HTTPS load balancers for Cloud Run |
| `infra-vector-search` | Vertex AI vector index, endpoint, and PSC attachment |
| `infra-bigquery` | Map-driven BigQuery datasets and tables |
| `infra-bq-dataset` | Single-dataset helper (legacy/simple use cases) |

**`terraform/projects/<name>/`** owns project-specific decisions and data:

- Resource names, CIDR ranges, static IPs, DNS records
- Bucket suffixes and optional KMS key suffixes (`static/main.tf`)
- Service account role lists (`static/main.tf`, `params.tfvars`)
- ILB service maps and SSL secret names (`infra/ilb_config.tf`)
- Vector search index/endpoint naming (`infra/main.tf`)
- BigQuery schemas and dataset/table maps (`infra/bq_datasets.tf`)

Example: aicoesandox supplies bucket names, reserved IP maps, DNS records, translation/sales-agent ILB services, vector search display names, and BigQuery schemas from its project layers while importing shared modules from `terraform/modules/`.

**Rule:** If a value is specific to one GCP project or application, keep it in project code (`main.tf`, `locals.tf`, `params.tfvars`, or project config files like `bq_datasets.tf`). If the Terraform resource pattern is reusable, generalize it into `terraform/modules/`. Shared modules should expose neutral output names such as `network_self_link`, `bucket_names`, or `reserved_internal_addresses` rather than project-prefixed outputs.

## CI/CD

- Root `.gitlab-ci.yml` — GitLab CI entrypoint
- `.gitlab/ci/terraform-project.yml` — shared Terraform plan/apply template
- [CONTRIBUTION.md](../CONTRIBUTION.md) — adding projects, lock files, state migration, CI checklist
- `rules:changes` provisions only the sandbox project folder or shared module that changed

## Labels and tags

### Canonical Terraform labels

Every project layer defines `local.default_labels` in `locals.tf` and applies it in two ways:

1. **Provider defaults** — `provider.tf` sets `default_labels = local.default_labels` on both `google` and `google-beta`.
2. **Module inputs** — label-capable modules receive `labels = local.default_labels` from the project layer `main.tf`.

Canonical keys:

| Key | Value |
|-----|-------|
| `environment` | `var.envname` (e.g. `sandox`, `dev`, `prod`) |
| `managed_by` | `terraform` |
| `project` | `var.project_name` (repo project folder name) |
| `team` | `ai-coe` |

New modules that create label-capable resources should accept a `labels` variable and use `labels = var.labels` rather than hardcoding keys.

### GCP Resource Manager tags

Project-level governance tags are created once in the **static** layer via `modules/static-base`:

- Tag key: `environment`
- Tag value: `var.envname`
- Binding: GCP project (`google_tags_tag_binding.env_project`)

The tag value ID is exposed as `module.base.env_tag_value_id` for downstream use. Do not duplicate tag key/value creation in network or infra layers.

### Resources without labels

Some resources cannot be labelled in Terraform/GCP. Rely on project-level tags and layer ownership instead:

- IAM bindings (`google_project_iam_member`, KMS IAM, bucket IAM)
- API enablement (`google_project_service`)
- Audit configs (`google_project_iam_audit_config`)
- DNS record sets (`google_dns_record_set`)
- BigQuery tables (labels are set on datasets; tables inherit dataset context)
- Router NAT configuration (`google_compute_router_nat`)
