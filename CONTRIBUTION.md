# Contributing to AICOE Terraform

This guide covers how to add projects, change shared modules, and keep state, CI, and provider pins consistent.

For layout and module catalogue, see [terraform/README.md](terraform/README.md).

---

## Principles

1. **Shared modules are generic** — no project-specific names, CIDRs, DNS hostnames, or fixed IPs inside `terraform/modules/`.
2. **Projects own values** — names, maps, APIs, IAM, schemas, and feature flags live under `terraform/projects/<name>/`.
3. **One state file per layer** — static, network, and infra each have their own GCS prefix.
4. **Plan before apply** — especially when migrating state or refactoring into modules.

---

## Toolchain (required)

| Item | Location | Notes |
|------|----------|--------|
| Terraform version | [`.terraform-version`](.terraform-version) | Currently `1.15.7`. CI installs from this file. |
| Provider lock | `<layer>/.terraform.lock.hcl` | **Commit this file.** Pins `google` / `google-beta` (e.g. `7.39.0`). |
| `required_version` | `<layer>/terraform.tf` | `~> 1.15.0` in every layer. |
| CI install script | [`.gitlab/ci/install-terraform.sh`](.gitlab/ci/install-terraform.sh) | Uses `HTTP_PROXY` / `HTTPS_PROXY` on the Shell1 runner. |

### Why `.terraform.lock.hcl` matters

- Locks provider **version and checksums** so local runs, CI, and teammates resolve the same provider binaries.
- **Must be committed** for every layer (`static`, `network`, `infra`).
- Without it, the next `terraform init` may download a newer `google` provider and produce unexpected plan diffs.
- It is **not** state and contains no secrets — safe to commit.

### Creating `.terraform.lock.hcl` (step by step)

Run these steps **once per layer** (static, network, infra) when adding a new project or a new layer.

#### Prerequisites

1. Install Terraform **1.15.7** (see [`.terraform-version`](.terraform-version)).
2. Authenticate to GCP (`gcloud auth application-default login` or a service account).
3. If behind corporate proxy, export proxy variables:

```bash
export HTTP_PROXY="${HTTP_PROXY:-http://your-proxy:8080}"
export HTTPS_PROXY="${HTTPS_PROXY:-$HTTP_PROXY}"
```

#### Step 1 — Go to the layer directory

```bash
cd terraform/projects/<project-name>/<layer>
# examples:
#   terraform/projects/pricing-agent/static
#   terraform/projects/aicoesandox/network
```

#### Step 2 — Remove any stale local init (optional but recommended)

```bash
rm -rf .terraform
```

#### Step 3 — Run `terraform init` with the correct backend

Use the real state bucket and prefix for that layer (from `Makefile` or `params.tfvars`):

```bash
terraform init \
  -backend-config 'bucket=<state-bucket>' \
  -backend-config 'prefix=<project-name>/tfstate-<layer>' \
  -input=false
```

Examples:

```bash
# aicoesandox static
terraform init \
  -backend-config 'bucket=aicoesandox-bucket-tf-state' \
  -backend-config 'prefix=aicoesandox/tfstate-static' \
  -input=false

# pricing-agent static
terraform init \
  -backend-config 'bucket=pricingagent-sandbox-bucket-tf-state' \
  -backend-config 'prefix=pricing-agent/tfstate-static' \
  -input=false
```

Or use Make (also runs `fmt` and safety prompt):

```bash
make init ENVNAME=sandbox SKIP_INTERACTIVE_SAFETY_PROMPT=true
```

#### Step 4 — Confirm the lock file was created

```bash
ls -la .terraform.lock.hcl
terraform version
terraform providers
```

You should see entries for `registry.terraform.io/hashicorp/google` (and `google-beta` if used in that layer).

#### Step 5 — Commit the lock file

```bash
git add .terraform.lock.hcl
git commit -m "Add provider lock file for <project> <layer>"
```

**Repeat steps 1–5 for each layer** (static, network, infra) — each layer has its own `.terraform.lock.hcl`.

#### Step 6 — Verify with a plan (recommended)

```bash
terraform plan -var-file=params.tfvars -input=false
```

If init fails to download providers (timeout), retry with proxy set, or copy provider cache from another layer that already initialized:

```bash
# only if registry download fails — use an existing layer's provider cache
PLUGIN_DIR=../../aicoesandox/static/.terraform/providers
terraform init \
  -backend-config 'bucket=<state-bucket>' \
  -backend-config 'prefix=<project-name>/tfstate-<layer>' \
  -reconfigure -input=false \
  -plugin-dir="$PLUGIN_DIR"
```

---

### Updating an existing lock file

When you **intentionally** upgrade providers (team decision):

```bash
cd terraform/projects/<project>/<layer>
rm -rf .terraform
terraform init \
  -backend-config 'bucket=<state-bucket>' \
  -backend-config 'prefix=<project-name>/tfstate-<layer>' \
  -upgrade \
  -input=false
terraform plan -var-file=params.tfvars   # review all projects using shared modules
git add .terraform.lock.hcl
```

When providers did **not** change but modules did:

```bash
terraform init \
  -backend-config 'bucket=<state-bucket>' \
  -backend-config 'prefix=<project-name>/tfstate-<layer>' \
  -input=false
# commit only if .terraform.lock.hcl changed
```

**Do not** hand-edit `.terraform.lock.hcl` unless you know what you are doing.

---

## Adding a new project

Use an existing project as a template (`aicoesandox` for full stack, `svcmgmtops` for static + infra only).

### 1. Create the folder layout

```
terraform/projects/<project-name>/
├── static/          # required first
├── network/         # optional
└── infra/           # optional (depends on static; often network too)
```

Each layer should contain at minimum:

| File | Purpose |
|------|---------|
| `main.tf` | Module calls only (no inline `resource` blocks) |
| `locals.tf` | `gcp_project_id`, `resource_prefix`, `state_bucket`, `default_labels` |
| `variables.tf` | Inputs with sensible `default = ""` where optional |
| `params.tfvars` | Environment values (committed) |
| `provider.tf` | `google` + `google-beta` with `default_labels` |
| `terraform.tf` | `required_version` + `backend "gcs" {}` |
| `outputs.tf` | Layer outputs (neutral names) |
| `Makefile` | init / plan / apply targets |
| `.terraform.lock.hcl` | Provider lock (**commit**) |

Optional project config files (keep values here, not in modules):

- `ilb_config.tf`, `bq_datasets.tf`, etc.

### 2. GCP and state prerequisites

Before the first apply:

1. **GCP project** exists; note the real **project ID** (`gcloud projects describe <id>`).
2. **State bucket** exists, e.g. `gs://<bucket>-bucket-tf-state`.
3. **WIF / service account** can read/write the bucket and manage resources in the GCP project.

Document the bucket in `terraform/README.md` (state table) and in the layer `Makefile`.

### 3. `params.tfvars` conventions

```hcl
project_name   = "<folder-name>"      # matches terraform/projects/<folder-name>
project        = "<short-code>"       # used in resource naming / make PROJECT=
envname        = "<environment>"      # sandox | sandbox | dev | prod
region         = "europe-west1"
gcp_project_id = "<real-gcp-project-id>"   # set explicitly when != project+envname
resource_prefix = "<prefix>"             # optional override
state_bucket   = "<bucket-name>"           # when bucket name uses hyphens or special rules
project_number = "<gcp-project-number>"
```

**Important:** `local.gcp_project_id` defaults to `"${var.project}${var.envname}"`. If the real GCP project ID is different (e.g. `aicoeaiworkshop` vs `aicoeaiworkshopsandox`), set `gcp_project_id` explicitly in `params.tfvars`.

### 4. Makefile conventions

Per layer, set:

```makefile
ENVNAME=sandbox                    # default for local make (match TF_ENV in CI)
PROJECT=<short-code>               # match params.tfvars project
PROJECT_NAME=<folder-name>         # match terraform/projects/<folder-name>
REGION=europe-west1
TFSTATE_BUCKET=<exact-gcs-bucket>  # must match real bucket name
TFSTATE_DIR=$(PROJECT_NAME)/tfstate-<layer>
TFPLAN_FILE=../../$(PROJECT_NAME)-<layer>-$(PROJECT)$(ENVNAME)-$(REGION)-tf.plan
LAYER=<layer>
```

Verify with:

```bash
make -n init | grep bucket
```

CI overrides `TFSTATE_BUCKET` via job variables; local defaults must still be correct.

### 5. State prefix

New projects use:

```
gs://<bucket>/<project_name>/tfstate-static/default.tfstate
gs://<bucket>/<project_name>/tfstate-network/default.tfstate
gs://<bucket>/<project_name>/tfstate-infra/default.tfstate
```

### 6. Migrating existing state (legacy layout)

If resources already exist under an old prefix (e.g. `tfstate-static/`):

1. **Copy** state to the new prefix (do not delete the old file until verified):

```bash
gsutil cp gs://<bucket>/tfstate-static/default.tfstate \
         gs://<bucket>/<project>/tfstate-static/default.tfstate
```

2. Add **`moved.tf`** in each layer mapping old root-module addresses to new module addresses (see `terraform/projects/aicoesandox/*/moved.tf`).
3. Align **resource names** in project code with what is already in GCP (bucket suffixes, KMS suffixes, dataset IDs).
4. Run **`terraform plan`** — target **0 destroys** before apply.
5. Apply layers in order: **static → network → infra**.

### 7. `moved.tf`

- Required when refactoring from inline resources to modules **without** recreating infrastructure.
- Safe to leave in place after migration; Terraform ignores blocks that no longer match state.
- Remove only when you are certain no one will replay old state.

### 8. GitLab CI (`.gitlab-ci.yml`)

For each layer, add plan + apply job pairs extending `.terraform_plan` / `.terraform_apply`:

| Job variable | Example | Notes |
|--------------|---------|--------|
| `PROJECT_NAME` | `my-project` | Folder under `terraform/projects/` |
| `TF_LAYER` | `static` | `static`, `network`, or `infra` |
| `TF_ENV` | `sandbox` | Passed to make as `ENVNAME` |
| `TF_PROJECT` | `myapp` | Passed to make as `PROJECT` |
| `GCP_PROJECT_ID` | `myapp-sandbox` | Real GCP project ID |
| `TFSTATE_BUCKET` | `myapp-sandbox-bucket-tf-state` | Exact bucket name |
| `TF_REGION` | `europe-west1` | Set globally or per job |

`rules:changes` should include:

```yaml
- terraform/projects/<project-name>/**
- terraform/modules/**
- .gitlab/ci/**
- .terraform-version
```

Wire **stage dependencies**: static apply before network; network apply before infra.

Apply jobs are **manual** by design.

### 9. Group IAM (`static-group-iam`)

- Only enable `module.group_iam` when the Google Group **exists** in Workspace.
- Legacy project branches often had group IAM **commented out** — confirm with the team before enabling.
- If the group does not exist, apply will fail with `Group ... does not exist`.

---

## Layer dependencies

```
static  →  network  →  infra
         ↘            ↗
          (infra reads static; full stacks also read network)
```

- **static** — APIs, tags, identities, storage, artifact registry.
- **network** — `terraform_remote_state.static`; VPC, NAT, DNS, reserved IPs.
- **infra** — `terraform_remote_state.static` (+ `network` when needed); BQ, ILB, notebook, vector search.

Remote state config pattern:

```hcl
data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    prefix = "${var.project_name}/tfstate-network"
  }
}
```

---

## Changing shared modules

1. Keep modules **neutral** — use variables/maps for anything that differs per project.
2. Prefer **neutral output names** (`network_self_link`, `bucket_names`) not `aicoe_*`.
3. After module changes, run **plan for every project** that uses the module (CI `changes` on `terraform/modules/**` triggers all affected jobs).
4. Update **`.terraform.lock.hcl`** only if provider requirements change.

---

## Labels and tags

Every project layer:

- `locals.tf` → `default_labels` (`environment`, `managed_by`, `project`, `team`)
- `provider.tf` → `default_labels = local.default_labels`
- Pass `labels = local.default_labels` into modules

Environment **tags** (Resource Manager) are created once in **static** via `static-base`; do not duplicate in network/infra.

---

## Local workflow

```bash
cd terraform/projects/<project>/<layer>
make plan ENVNAME=<env>    # or rely on Makefile ENVNAME default
make apply ENVNAME=<env>   # after reviewing plan artifact
```

For init without Makefile `clean` wiping `.terraform`:

```bash
terraform init \
  -backend-config 'bucket=<bucket>' \
  -backend-config 'prefix=<project>/tfstate-<layer>'
terraform plan -var-file=params.tfvars
```

---

## Checklist (new project)

- [ ] Folder `terraform/projects/<name>/{static,network?,infra?}` created
- [ ] GCP project ID verified in console (`gcloud projects describe`)
- [ ] State bucket exists; prefix documented
- [ ] `params.tfvars` — explicit `gcp_project_id` / `state_bucket` if defaults are wrong
- [ ] `Makefile` per layer — correct `TFSTATE_BUCKET`, `TFSTATE_DIR`, `ENVNAME`
- [ ] `terraform.tf` — `required_version = "~> 1.15.0"`
- [ ] `.terraform.lock.hcl` per layer — **committed**
- [ ] State copied from legacy prefix if migrating
- [ ] `moved.tf` if migrating from inline resources to modules
- [ ] Plan shows **no unexpected destroys**
- [ ] `.gitlab-ci.yml` jobs for each layer
- [ ] Row added to state table in `terraform/README.md`
- [ ] Group IAM only if Google Group exists

---

## Checklist (PR / change)

- [ ] `terraform fmt` run on changed `.tf` files
- [ ] Plan output reviewed for destroy/replace
- [ ] `.terraform.lock.hcl` updated and committed if providers changed
- [ ] No project-specific values added to `terraform/modules/`
- [ ] README / CONTRIBUTION updated if conventions change

---

## Common pitfalls

| Issue | Cause | Fix |
|-------|--------|-----|
| Terraform wants to recreate everything | Empty state at new prefix | Copy state from old prefix first |
| Wrong GCP project in plan | `project` + `envname` ≠ real project ID | Set `gcp_project_id` in `params.tfvars` |
| `make init` uses wrong bucket | `TFSTATE_BUCKET` default wrong | Match real bucket; pass `ENVNAME` |
| Group IAM apply fails | Group not in Google Workspace | Comment out `group_iam` or create group |
| API index destroy/recreate | `gcp_apis_required` order changed | Match order in existing state |
| Bucket name mismatch after module move | Wrong `bucket_suffixes` / `resource_prefix` | Match names already in GCP/state |
| CI cannot download Terraform | No proxy on runner | Set `HTTP_PROXY` / `HTTPS_PROXY` in GitLab CI/CD variables |

---

## References

- [terraform/README.md](terraform/README.md) — layout, modules, labels, state table
- [`.gitlab/ci/terraform-project.yml`](.gitlab/ci/terraform-project.yml) — CI template
- [`.terraform-version`](.terraform-version) — Terraform pin
- Example full stack: `terraform/projects/aicoesandox/`
- Example minimal stack: `terraform/projects/svcmgmtops/`
