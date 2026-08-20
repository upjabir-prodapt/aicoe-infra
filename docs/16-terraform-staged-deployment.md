# 16 — Terraform Staged Deployment Reference Guide

**Revision R13.** Operational design, stages, security model, and execution procedures for the staged-deployment model in the AI CoE GCP Terraform platform.

---

## 1. Purpose and Scope

This document serves as the authoritative operational guide for deploying, maintaining, and understanding the AI CoE GCP Terraform infrastructure. The platform is designed to be a highly secure, greenfield AI environment deployed across nine Google Cloud projects in strictly ordered, independent stages.

### 1.1 Principles
*   **Sequential Stage Order:** Infrastructure is applied in numbered stages ($0$ through $7$). Downstream stages are never planned or applied before all preceding stages have succeeded.
*   **State Isolation:** There is no cross-stage remote state lookup (`terraform_remote_state` data sources). A stage's credentials can access its own state bucket prefix and nothing else.
*   **Explicit Contracts:** Stages pass outputs to downstream consumers via ordinary variables populated from exported `<stage>.auto.tfvars.json` artifacts, enforcing clear boundaries.

---

## 2. Stage Architecture & Dependencies

The infrastructure is broken into numbered stages representing the actual dependency graph of the platform.

```
0-bootstrap ──> 1-org ──> 2-foundations ──> 3-network ──> 4-apigee
                                              │               │
                                              v               v
                                        5-network-psc <───────┘
                                              │
                                              v
                                       6a-aihub-ui ──┐
                                       6b-st ────────┼─> 6c-ingress ──> 7-apigee-runtime
```

### 2.1 Detailed Stage Inventory

| Stage | Name | Target Project / Context | Purpose / Key Resources Created |
| :--- | :--- | :--- | :--- |
| **0** | `0-bootstrap` | `aicoe-sharedwif` (Seed) | **Manual, once.** Creates GCS state bucket, KMS keys, Workload Identity Pool/Provider, and per-project `tf-deployer` SAs. |
| **1** | `1-org` | Folder-level / All Projects | **Read-only.** Queries existing project IDs and numbers to output an authoritative map. Creates no resources. |
| **2** | `2-foundations` | All 8 Projects | Enables APIs, forces Lazy Service Agent creation, provisions KMS Key Rings, Artifact Registry, Model Armor templates, and the log bucket. |
| **3** | `3-network` | `gclt-aicoe-dev-network` | VPC, Subnets (Internal, Cloud Run, Proxy, PSC NAT), DNS Private Zones, Firewall Rules, Shared VPC Host project enablement. |
| **4** | `4-apigee` | `gclt-aicoe-dev-apigee` | **Slow (30-60m).** Provisions Apigee Organization, Instance, and Environments (`int` and `llm`). |
| **5** | `5-network-psc` | `gclt-aicoe-dev-network` | Private Service Connect (PSC) endpoint targeting Stage 4's Apigee Service Attachment. DNS records for `aihub-api` and `llm`. |
| **6a** | `6a-aihub-ui` | `gclt-aicoe-dev-aihub-ui` | BFF Backend Service and Network Endpoint Group (NEG). Configures IAP for UI access. |
| **6b** | `6b-st` | `gclt-aicoe-dev-st` | Usecase backend Cloud Run services, NEGs, and `run.invoker` permissions. |
| **6c** | `6c-ingress` | `gclt-aicoe-dev-ingress` | **The cross-project join.** Regional external HTTP(S) Load Balancer frontends, routing to Stage 6a and 6b backend NEGs. |
| **7** | `7-apigee-runtime` | `gclt-aicoe-dev-apigee` | Apigee Endpoint Attachments (southbound targeting 6c's Service Attachment), Target Servers, and Key-Value Maps (KVMs). |

---

## 3. The tfvars Handoff Pattern

Downstream stages consume upstream outputs using standard Terraform variables. Remote state files (`data.terraform_remote_state`) are forbidden.

### 3.1 GitLab CI / Local Handoff Mechanism
In the GitLab pipeline, stages output their variables to JSON, which is passed as an artifact to downstream stages:
```bash
# Export step (run inside Stage directory after successful apply)
terraform output -json | jq 'map_values(.value)' > "${STAGE}.auto.tfvars.json"
```

Terraform automatically loads any file matching `*.auto.tfvars.json` in the current working directory, translating the JSON keys directly into root-level variable values.

### 3.2 Handoff Reference Matrix

| Stage | Consumes | From Stage | Outputs / Publishes |
| :--- | :--- | :--- | :--- |
| **0-bootstrap** | — | — | `state_bucket`, `deployer_emails`, `pool_name`, `provider_name`, `wif_project_number` |
| **1-org** | — | — | `project_ids`, `project_numbers` |
| **2-foundations** | — | — | *(None — side-effects only)* |
| **3-network** | — | — | `vpc_self_link`, `subnet_ew1_self_link`, `cloudrun_subnet_self_link`, `proxy_subnet_self_link`, `pscnat_subnet_self_link`, `internal_subnet_self_link`, `private_zone_name`, `googleapis_zone_name` |
| **4-apigee** | — | — | `org_id`, `instance_service_attachment`, `environments` |
| **5-network-psc** | `vpc_self_link`, `internal_subnet_self_link`, `private_zone_name`<br>`instance_service_attachment` | `3-network`<br>`4-apigee` | `apigee_endpoint_ip`, `google_apis_ip` |
| **6a-aihub-ui** | — *(Ordering only)* | `5-network-psc` | `bff_backend_service_self_link` |
| **6b-st** | — *(Ordering only)* | `5-network-psc` | `translation_backend_service_self_link`, `sales_backend_service_self_link` |
| **6c-ingress** | `vpc_self_link`, `subnet_ew1_self_link`, `internal_subnet_self_link`, `pscnat_subnet_self_link`<br>`bff_backend_service_self_link`<br>`translation_backend_service_self_link`, `sales_backend_service_self_link` | `3-network`<br>`6a-aihub-ui`<br>`6b-st` | `backend_service_attachment_id` |
| **7-apigee-runtime** | `org_id`<br>`backend_service_attachment_id` | `4-apigee`<br>`6c-ingress` | `endpoint_attachment_host` |

---

## 4. Identity & Access Control (WIF & SAs)

The platform follows a strict least-privilege model for automated deployments, isolating credentials by project boundaries.

### 4.1 Workload Identity Federation (WIF)
*   **Shared Pool:** A single WIF pool (`gitlab-pool`) and provider (`gitlab-provider`) live in the seed project `aicoe-sharedwif`. This handles GitLab OIDC authentication.
*   **Security Control:** The provider's `attribute_condition` limits impersonation to specific repos on protected branches (e.g. `main` / `master`):
    ```hcl
    attribute.project_path in ["your-org/aicoe-terraform"] && attribute.ref_protected == "true"
    ```
*   **Strict Security Rule:** Never widen this OIDC attribute condition globally. Doing so collapses the separation between Dev and Prod pipelines.

### 4.2 Per-Project Deployment Service Accounts
Instead of using one "all-powerful" pipeline service account, stage $0$ provisions one `tf-deployer` service account **per project** inside that project:
*   `tf-deployer@gclt-aicoe-dev-network.iam.gserviceaccount.com`
*   `tf-deployer@gclt-aicoe-dev-apigee.iam.gserviceaccount.com`
*   ...and so on.

The GitLab runner authenticates using WIF and then impersonates the specific `tf-deployer` SA of the target project (`TF_PROJECT`) to run the stage's Terraform plan/apply.

### 4.3 State Bucket IAM Prefix Scoping
To prevent a compromised project SA from accessing or overwriting state files belonging to other projects, Stage 0 attaches a conditional IAM policy to the central state bucket:
```hcl
resource "google_storage_bucket_iam_member" "state_access" {
  bucket   = google_storage_bucket.state.name
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${each.value.email}"

  condition {
    title      = "own-prefix-only"
    expression = "resource.name.startsWith(\"projects/_/buckets/${google_storage_bucket.state.name}/objects/${each.key}/\")"
  }
}
```
*   `each.key` corresponds to the project ID (e.g. `gclt-aicoe-dev-network`).
*   **Important Caveat / Verification Item:** The GitLab runner specifies the state prefix as the stage directory basename (e.g. `3-network`). Ensure your stage prefixes match the project ID structure or the conditional path matches the actual folder basenames (e.g., `gclt-aicoe-dev-network` prefix), otherwise prefix-scoping will deny state write access.

---

## 5. Pipeline Mechanics (GitLab CI)

Deployments are coordinated by the repository root `.gitlab-ci.yml`.

### 5.1 Pipeline Stages
1.  **`validate`**: Runs formatting check (`fmt`), validation (`validate-all.sh`), and the security `policy-check.sh` on all code.
2.  **Infrastructure Stages (1 through 7)**: Executed sequentially.
    *   **Manual Gate:** Stage `4-apigee` is explicitly gated as `when: manual` in the pipeline with a 2-hour timeout. This is due to its slow, immutable nature.
3.  **`proxies`**: Deploys Apigee API proxies, products, and KVM configurations using `apigeecli` (non-Terraform script).

### 5.2 Concurrency Protection
Every runner job uses GitLab's `resource_group: ${STAGE}`. This serializes applies to prevent concurrent execution conflicts on the same state files.

---

## 6. Local & Manual Deployment Runbook

Local execution should closely mirror CI and respect all safety gates.

### 6.1 Authentication Setup
Set up Application Default Credentials (ADC) to use your local console permissions:
```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project aicoe-sharedwif
```

*Note: Workload Identity Federation is only used by the CI runner. Locally, your session runs as your human administrator identity unless you explicitly configure service account impersonation (`GOOGLE_IMPERSONATE_SERVICE_ACCOUNT`).*

### 6.2 Per-Stage Variable Mapping
Locally, you must pass environment-wide tfvars alongside stage-specific variables:
1.  `envs/dev/terraform.tfvars`: Carries environment variables (KMS ring names, CIDRs, region, project names).
2.  `envs/dev/stages/<stage>.tfvars`: Carries only the `project_id` for that specific target project (which is set by CI variables in the pipeline).

Command pattern:
```bash
terraform plan \
  -var-file="$TF_ROOT/envs/dev/terraform.tfvars" \
  -var-file="$TF_ROOT/envs/dev/stages/3-network.tfvars" \
  -out=tfplan
```

### 6.3 Local tfvars Handoff (Manual Artifacts)
When applying locally, manually export the output of the preceding stage to the repo root before moving to the next stage:
```bash
# Inside applied stage directory:
terraform output -json | jq 'map_values(.value)' > "$TF_ROOT/<stage-basename>.auto.tfvars.json"

# Move to next stage directory and selectively copy required dependencies:
cd "../5-network-psc"
cp "$TF_ROOT/3-network.auto.tfvars.json" .
cp "$TF_ROOT/4-apigee.auto.tfvars.json" .
```

---

## 7. Operational Apply Workflow (Safety Rules)

Every deployer (whether human or automated subagent) MUST strictly adhere to the following sequence when planning and applying a stage.

```
[Engage Stage] ────────> [Review Configuration] ────────> [State Intent to User]
                                                                  │
                                                                  v
[Apply Stage] <── [Explicit Go-Ahead] <── [Pre-Apply Summary] <── [Run Plan & Show Diff]
      │
      v
[Wait to Complete] ──> [Troubleshoot Errors (If Any)] ──> [Verify Outcomes & Outputs]
```

### 7.1 The Nine Steps of Staged Apply
1.  **Understand the Stage:** Review the stage's code, variables, and position in the sequence. Understand what resources will be managed.
2.  **State Intent:** Tell the user in plain, clear language what stage you are engaging, what it does, and what you are about to run.
3.  **Cross-Stage Check:** Copy the selectively needed `.auto.tfvars.json` files from upstream stages into your workspace directory. Verify that all referenced variables are declared.
4.  **Explain Code Changes (If Any):** If any edits are required to make the configuration fit, explain the changes and their rationale to the user *before* making them.
5.  **Plan:** Execute `terraform plan` and print the resulting diff. Check for unexpected drift, destroys, or modifications.
6.  **Pre-Apply Summary:** Present a summary of:
    *   The stage's overall goal.
    *   Specific resources, services, or variables that will spin up or change.
    *   Why this change is needed now.
7.  **Explicit Go-Ahead:** Explicitly ask the user for a clear confirmation (e.g. `"yes, apply"`) before running `terraform apply`.
8.  **Apply and Wait:** Execute `terraform apply`. Some stages (particularly Network, Apigee, and PSC) take a long time to provision. Wait patiently for the command to exit.
9.  **Post-Apply Verification:** Verify that the command exited successfully ($0$). Inspect `terraform output`. Confirm the exported `<stage>.auto.tfvars.json` file is correctly formatted and holds valid outputs.

### 7.2 Error Handling & Troubleshooting
*   **Fail-Stopped Principle:** If a `terraform apply` fails, DO NOT move on. Stop immediately.
*   **Analyze and Resolve:** Troubleshoot the root cause within the current stage. Update configuration or fix the environment constraint as necessary.
*   **Re-Apply:** Run `plan` and `apply` again on the *same* stage and verify success before proceeding to any downstream stages.

---

## 8. Immutable Resources & Ordering Traps

Some GCP and Apigee resources are immutable once created or are highly prone to ordering failures.

### 8.1 Immutable Configurations (Destroy & Recreate Required)
*   **Apigee Organization Provisioning:** The following properties are immutable:
    *   `disable_vpc_peering = true` (peering is non-transitive).
    *   `runtime_database_encryption_key_name` (must be specified at creation time).
    *   `analytics_region = europe-west2` (cannot change after creation).
    *   `consumer_accept_list` (must restrict to the network project).
*   **KMS Keys:** Deletion has a mandatory 24-hour to 30-day waiting period. Data encrypted with disabled/destroyed keys is permanently unrecoverable.
*   **State Bucket & Pin Address:** The state bucket name and the internal ingress frontend address (`10.110.73.20`) carry explicit `prevent_destroy` life-cycle rules.

### 8.2 Common Ordering Traps
*   **The Lazy Service Agent Trap:** GCP service agents are created lazily. If you attempt to grant IAM roles (such as KMS Decrypter) to a service agent before GCP spins it up, the apply will fail. Resolve by forcing service agent creation using `gcloud beta services identity create` or using Stage 2 (`2-foundations`) which executes this before resource creation.
*   **The Ingress Certificate Gate (P4):** Stage `6c-ingress` will fail if the required SSL certificates (`aihub_certificate_id` and `backend_certificate_id`) do not already exist in GCP's Certificate Manager.

---

## 9. Troubleshooting Quick Reference

| Symptom | Cause | Fix |
| :--- | :--- | :--- |
| `Reference to undeclared module` (Stage 0) | Stale branch checkout containing old pre-bootstrap dependencies. | Checkout a fresh copy of the codebase. |
| Prompts for `project_id` on local run | Missing stage-specific tfvars file. | Create `envs/dev/stages/<stage>.tfvars` with `project_id = "<value>"`. |
| Shared VPC attachment fails (Permission Denied) | `roles/compute.xpnAdmin` is missing on the folder level. | Grant folder-level xpnAdmin to your identity/SA. |
| Apigee forwarding rule status `PENDING` | Network project not in Stage 4's Apigee consumer accept list. | Update `consumer_accept_list` in Stage 4 and re-apply. |
| Stage 4 appears hung for 40 minutes | Normal provisioning latency for Apigee instances. | **Wait.** Do not interrupt the apply command mid-way. |
| Cloud Run NEG binding fails (Stage 6a/6b) | Cloud Run services not yet deployed from application code. | Deploy the serverless services using application pipelines before running Stage 6. |

---

## 10. Stage-by-Stage Local Execution Reference

This section outlines the exact local terminal execution runbook, commands, and copying procedures for each numbered stage using our centralized `terraform/vars-handoff/` directory.

### 10.1 Stage 0 — Bootstrap (State Setup)
**Run once manually.** Sets up state GCS bucket, CMEK, and deployer SAs.
```bash
cd terraform/0-bootstrap
terraform init
terraform plan -var-file="../envs/dev/terraform.tfvars" -out=tfplan
terraform apply tfplan

# Capture state bucket name and migrate state
export TF_STATE_BUCKET="$(terraform output -raw state_bucket)"
mkdir -p ../vars-handoff
terraform output -json | jq 'map_values(.value)' > ../vars-handoff/0-bootstrap.auto.tfvars.json

# Uncomment `backend "gcs" {}` in `main.tf`
terraform init -migrate-state \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="prefix=0-bootstrap"
```

### 10.2 Stage 1 — Org (Read-Only Inventory)
Queries the existing GCP projects.
```bash
cd ../1-org
terraform init -reconfigure -backend-config="bucket=${TF_STATE_BUCKET}" -backend-config="prefix=1-org"
terraform plan -var-file="../envs/dev/terraform.tfvars" -out=tfplan
terraform apply tfplan
mkdir -p ../vars-handoff
terraform output -json | jq 'map_values(.value)' > ../vars-handoff/1-org.auto.tfvars.json
```

### 10.3 Stage 2 — Foundations (Core Base)
```bash
cd ../2-foundations
cp ../vars-handoff/1-org.auto.tfvars.json .
terraform init -reconfigure -backend-config="bucket=${TF_STATE_BUCKET}" -backend-config="prefix=2-foundations"
terraform plan -var-file="../envs/dev/terraform.tfvars" -var="certs_enabled=true" -out=tfplan
terraform apply tfplan
mkdir -p ../vars-handoff
terraform output -json | jq 'map_values(.value)' > ../vars-handoff/2-foundations.auto.tfvars.json
```

### 10.4 Stage 3 — Network (VPC, Subnets, DNS, Host enablement)
```bash
cd ../3-network
cp ../vars-handoff/1-org.auto.tfvars.json .
terraform init -reconfigure -backend-config="bucket=${TF_STATE_BUCKET}" -backend-config="prefix=3-network"
terraform plan -var-file="../envs/dev/terraform.tfvars" -var-file="../envs/dev/stages/3-network.tfvars" -out=tfplan
terraform apply tfplan
mkdir -p ../vars-handoff
terraform output -json | jq 'map_values(.value)' > ../vars-handoff/3-network.auto.tfvars.json
```

### 10.5 Stage 4 — Apigee (Immutable Org/Instance)
```bash
cd ../4-apigee
cp ../vars-handoff/1-org.auto.tfvars.json .
terraform init -reconfigure -backend-config="bucket=${TF_STATE_BUCKET}" -backend-config="prefix=4-apigee"
terraform plan -var-file="../envs/dev/terraform.tfvars" -var-file="../envs/dev/stages/4-apigee.tfvars" -out=tfplan
terraform apply tfplan
mkdir -p ../vars-handoff
terraform output -json | jq 'map_values(.value)' > ../vars-handoff/4-apigee.auto.tfvars.json
```

### 10.6 Stage 5 — Network PSC (Apigee & API Endpoints)
```bash
cd ../5-network-psc
cp ../vars-handoff/3-network.auto.tfvars.json .
cp ../vars-handoff/4-apigee.auto.tfvars.json .
terraform init -reconfigure -backend-config="bucket=${TF_STATE_BUCKET}" -backend-config="prefix=5-network-psc"
terraform plan -var-file="../envs/dev/terraform.tfvars" -var-file="../envs/dev/stages/5-network-psc.tfvars" -out=tfplan
terraform apply tfplan
mkdir -p ../vars-handoff
terraform output -json | jq 'map_values(.value)' > ../vars-handoff/5-network-psc.auto.tfvars.json
```

**Execution Log (2026-08-16 - Routable IP & Model Armor Regional Alignment):**
1. **Firewall Exception in Stage 3:** Shifted egress destination IP from `192.168.6.146/32` to the routable `10.110.73.10/32` IP in the Stage 3 Network VPC firewall, and authorized `192.168.6.148/32` for regional Model Armor. Applied Stage 3 first.
2. **Routable Apigee IP Setup:** Swapped Apigee PSC endpoint in Stage 5 from the `gclt-aicoe-dev-internal-ew3` subnetwork (RFC 1918 unrouted range) to `subnet_ew3_self_link` (`10.110.73.0/24`) at static IP `10.110.73.10` to satisfy central Colt DNS registration requirements.
3. **Model Armor Regional PSC Endpoint:** Created a `google_network_connectivity_regional_endpoint` resource pointing to `modelarmor.europe-west3.rep.googleapis.com` in Frankfurt, using static IP `192.168.6.148` inside the internal subnet, coupled with a narrow private DNS zone and record set.
4. **Service Class API Enablement:** Enabled `aiplatform.googleapis.com` on `gclt-aicoe-dev-network` (the Shared VPC host project) to authorize the Network Connectivity API to recognize and resolve regional endpoint/service classes.
5. **Applied Cleanly:** Successfully deployed 9 of 10 resources in Stage 5. The automatic Vector Search service connection policy was commented out because the `gcp-aiplatform-vector-search` service class is restricted/unavailable in the regional backend for Service Connection Policies at this time.
6. **Output Handoff:** Exported `5-network-psc.auto.tfvars.json` containing `apigee_endpoint_ip = "10.110.73.10"`, `google_apis_ip = "192.168.6.164"`, and `model_armor_ip = "192.168.6.148"`.

### 10.7 Stage 6a — AI Hub UI (Cloud Run BFF backend)
```bash
cd ../6-workloads/6a-gclt-aicoe-dev-aihub-ui
terraform init -reconfigure -backend-config="bucket=${TF_STATE_BUCKET}" -backend-config="prefix=6-workloads/6a-gclt-aicoe-dev-aihub-ui"
terraform plan -var-file="../../envs/dev/terraform.tfvars" -var-file="../../envs/dev/stages/6a.tfvars" -out=tfplan
terraform apply tfplan
mkdir -p ../../vars-handoff
terraform output -json | jq 'map_values(.value)' > ../../vars-handoff/6a-gclt-aicoe-dev-aihub-ui.auto.tfvars.json
```

### 10.8 Stage 6b — ST (ST backends & Cloud Tasks)
```bash
cd ../6b-gclt-aicoe-dev-st
terraform init -reconfigure -backend-config="bucket=${TF_STATE_BUCKET}" -backend-config="prefix=6-workloads/6b-gclt-aicoe-dev-st"
terraform plan -var-file="../../envs/dev/terraform.tfvars" -var-file="../../envs/dev/stages/6b.tfvars" -out=tfplan
terraform apply tfplan
mkdir -p ../../vars-handoff
terraform output -json | jq 'map_values(.value)' > ../../vars-handoff/6b-gclt-aicoe-dev-st.auto.tfvars.json
```

### 10.9 Stage 6c — Ingress (The Ingress LB Join)
```bash
cd ../6c-gclt-aicoe-dev-ingress
cp ../../vars-handoff/1-org.auto.tfvars.json .
cp ../../vars-handoff/2-foundations.auto.tfvars.json .
cp ../../vars-handoff/3-network.auto.tfvars.json .
cp ../../vars-handoff/6a-gclt-aicoe-dev-aihub-ui.auto.tfvars.json .
cp ../../vars-handoff/6b-gclt-aicoe-dev-st.auto.tfvars.json .
terraform init -reconfigure -backend-config="bucket=${TF_STATE_BUCKET}" -backend-config="prefix=6-workloads/6c-gclt-aicoe-dev-ingress"
terraform plan -var-file="../../envs/dev/terraform.tfvars" -var-file="../../envs/dev/stages/6c.tfvars" -out=tfplan
terraform apply tfplan
mkdir -p ../../vars-handoff
terraform output -json | jq 'map_values(.value)' > ../../vars-handoff/6c-gclt-aicoe-dev-ingress.auto.tfvars.json
```

### 10.10 Stage 7 — Apigee Runtime (Southbound attachments)
```bash
cd ../../7-apigee-runtime
cp ../vars-handoff/1-org.auto.tfvars.json .
cp ../vars-handoff/4-apigee.auto.tfvars.json .
cp ../vars-handoff/6c-gclt-aicoe-dev-ingress.auto.tfvars.json .
terraform init -reconfigure -backend-config="bucket=${TF_STATE_BUCKET}" -backend-config="prefix=7-apigee-runtime"
terraform plan -var-file="../envs/dev/terraform.tfvars" -var-file="../envs/dev/stages/7-apigee-runtime.tfvars" -out=tfplan
terraform apply tfplan
mkdir -p ../vars-handoff
terraform output -json | jq 'map_values(.value)' > ../vars-handoff/7-apigee-runtime.auto.tfvars.json
```
