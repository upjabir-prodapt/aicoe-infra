# AI CoE Dev Platform — Build Log & Status

**Date:** 2026-08-14
**Built by:** jabir.mohammed@colt.net (with AI assistance)
**Environment:** Development (`gclt-aicoe-dev-*`)
**Source design:** LLD v2.0.2, Terraform package R13

---

## 1. Purpose

This document records the step-by-step provisioning of the AI CoE dev platform from the AI-generated Terraform package. It captures what was done, every blocker hit and how it was fixed, decisions made, and what remains.

**Context:** This is a **migration** — the new `gclt-aicoe-dev-*` estate replaces the existing `aicoedev` project, which will be decommissioned. We reuse the `aicoedev-int.colt.net` domains and the existing CA-issued certificates.

---

## 2. The Six Stages (build order)

| Stage | Purpose | Status |
|---|---|---|
| **0-bootstrap** | State bucket, CMEK key, 8 `tf-deployer` SAs, GitLab WIF pool | ✅ **COMPLETE** |
| **1-org** | Read-only: verify the 7 existing projects, publish IDs | ✅ **COMPLETE** |
| **2-foundations** | APIs, service agents, KMS, Artifact Registry, logging, Firestore, binauth, secrets, certs | ✅ **COMPLETE** (Model Armor parked) |
| **3-network** | VPC, 5 subnets, firewall, DNS, Shared VPC | ⏳ **NEXT** |
| **4-apigee** | Apigee org, instance, `int`+`llm` environments (30–60 min, immutable) | ⬜ Pending |
| **5-network-psc** | PSC endpoints to Apigee + Google APIs | ⬜ Pending |

**Later stages (blocked on items outside this repo):**
- **6a/6b** — Cloud Run workloads; need the app images deployed first (Translation, Sales Agent via GitLab)
- **6c** — Load balancers; needs 6a+6b + both certs (certs now done ✅)
- **7-apigee-runtime** — needs 6c; also where Model Armor attaches

---

## 3. Environment & Tooling Setup

| Item | Detail |
|---|---|
| Terraform | 1.9.8 (installed to `~/bin/terraform`, matches CI) |
| Auth | `jabir.mohammed@colt.net`, ADC via `gcloud auth application-default login` |
| Build machine | Sandbox VM `aicoesandox-notebook-test` (europe-west1-b), reaches Google APIs via PSC endpoint `192.168.2.3` |
| State backend | `gs://aicoe-sharedwif-tfstate` (versioned, CMEK) |
| Per-stage tfvars | Created under `envs/dev/stages/*.tfvars` (project_id per stage) |

---

## 4. Stage 0 — Bootstrap ✅

**What was created:**
- KMS key ring + key `tfstate` (europe-west1)
- State bucket `aicoe-sharedwif-tfstate` (versioning on, CMEK, `prevent_destroy`)
- 8 `tf-deployer` service accounts (one per project)
- GitLab WIF pool `gitlab-pool` + provider `gitlab-provider`
- Seed project APIs codified in Terraform (`google_project_service.seed`)

**Blockers hit & fixed:**

1. **KMS API not enabled in seed project** → `403 API not used`. Fixed by enabling `cloudkms`, `storage`, `iam`, `iamcredentials` (then codified in Terraform per the "APIs through Terraform only" decision).

2. **State migration silently failed** — `yes | terraform init -migrate-state` answered the wrong prompt; empty state was written to the bucket and local state was deleted. **State was lost.** Recovered by `terraform import` of all 26 resources (SAs first to unblock the `for_each` chain, then KMS, bucket with project-qualified ID, IAM members with condition title appended). **Lesson: never pipe `yes` into `init -migrate-state`; answer interactively.**

3. **Stale state lock** after the failed migration → cleared with `terraform force-unlock`.

**GitLab WIF configuration (corrected to match the working aicoedev pool):**
- Issuer: `https://amsgit01` (from the OIDC discovery doc, not `amsgit01.colt.net`)
- Audience: `https://iam.googleapis.com` (matches the working Translation pipeline's `aud`)
- **JWKS embedded** in the provider (`0-bootstrap/gitlab-jwks.json`) because `amsgit01` is internal-only — Google cannot fetch keys over the internet. **Note: must update this file when GitLab rotates signing keys.**
- Attribute condition allows 3 repos (real paths under `code-scanning-toolset`): `aicoe-terraform`, `translation`, `sales-agent`, restricted to protected branches.

---

## 5. Stage 1 — Org (read-only) ✅

Creates nothing. Reads the 7 existing projects via data sources and publishes their IDs/numbers to `1-org.auto.tfvars.json` for downstream stages. Confirmed the project inventory matches reality.

---

## 6. Stage 2 — Foundations ✅ (127 resources)

The largest stage. Created across all 7 projects: APIs, service agents, KMS rings/keys + grants, Artifact Registry (CMEK, immutable tags), Binary Authorization attestor + policies, the 400-day log bucket (CMEK, Log Analytics) + linked BigQuery dataset + folder sink, Firestore session store, BigQuery jobs dataset, Cloud Storage artifacts bucket, Secret Manager containers, 8 folder-level Data Access audit configs, and the 2 TLS certificates.

### Decisions made

- **Logging:** only the 400-day bucket in `gclt-aicoe-dev-auditlogs`. Sinks 2 (org copy) and 3 (SIEM Pub/Sub) **removed** per user decision. `org_log_project` variable deleted.
- **APIs through Terraform only** — no `gcloud services enable` by hand.
- **Certificates: self-managed in Certificate Manager** (not Google DNS-01 managed). Reuse the aicoedev CA-issued certs. PEMs stored in Secret Manager, read via data sources. Gate P4 superseded.
- **Domain:** `aicoedev-int.colt.net` throughout (changed from `aicoe-dev-int.colt.net` in 4 files: 3-network, 4-apigee, 5-network-psc, 2-foundations/ingress).
- **Firestore: no CMEK for now** (allowlist pending) — see blockers.

### Blockers hit & fixed (real code bugs in the AI-generated package)

1. **`apigee_llm_runtime_sa` circular input** — the variable was declared but the SA is created in the same stage. Plan hung prompting for it (hidden by a `| tail` pipe). **Fixed:** `gclt-aicoe-dev-llm.tf` now references `module.gclt_aicoe_dev_apigee_baseline.service_accounts["apigee-llm-runtime"]` directly.

2. **KMS `for_each` on apply-time emails** — `modules/kms-ring` built `for_each` keys from service-agent emails unknown until apply → plan-time failure. **Fixed:** static `key:index` keys; email kept in the value; null members filtered.

3. **Service-agent emails null** — `google_project_service_identity.email` is not populated for some services (bigquery, storage, secretmanager). **Fixed:** `modules/service-agents` now builds emails deterministically from the project number using Google's documented per-service patterns, falling back to the resource email when present.

4. **Duplicate `tf-deployer` SAs** — Stage 0 creates them; Stage 2's `project-baseline` tried to recreate them → `409 alreadyExists`. **Fixed:** removed `tf-deployer` from all Stage 2 `service_accounts` maps.

5. **auditlogs project had no API enablement** — no `project-baseline` module, so `cloudkms` was never enabled → KMS ring failed. **Fixed:** added `google_project_service` for cloudkms/logging/pubsub/bigquery + `depends_on`.

6. **Log bucket CMEK grant wrong identity** — granted the generic logging agent, but CMEK needs the special `service-<number>@gcp-sa-logging` account. **Fixed:** grant now uses `data.google_logging_project_settings.kms_service_account_id`.

7. **Invalid Firestore folder audit config** — `firestore.googleapis.com` doesn't support folder-level audit config → `400 badRequest`. **Fixed:** removed from the list.

8. **Binary Authorization empty attestor** — policies referenced `var.attestor_name` (empty). **Fixed:** wired to the real attestor ID `google_binary_authorization_attestor.gclt_aicoe_dev_ingress_build.id`.

9. **Secret Manager service identity missing** (aihub-ui) — secrets with CMEK failed. **Fixed:** added `secretmanager` to agent_services + a `session` key grant.

10. **Model Armor TLS failure** — the regional endpoint `modelarmor.europe-west1.rep.googleapis.com` fails TLS through the sandbox PSC/proxy (cert doesn't cover `.rep.googleapis.com`). **Fixed (partial):** provider overridden to the global endpoint (`model_armor_custom_endpoint`). See parked items.

### Certificates (done)

Both certs copied from aicoedev Secret Manager and created in Certificate Manager:
- `cert-aihub` → `aihub.aicoedev-int.colt.net` (expires 2028-06-15)
- `cert-backend` → `backend.aicoedev-int.colt.net` (expires 2028-08-12)

**Blocker hit & fixed:** the source PEMs had `subject=`/`issuer=` text lines between cert blocks → `400 detected unexpected data before N PEM block`. **Fixed:** stripped to PEM-only lines, dropped the self-signed root (Certificate Manager wants leaf + intermediate only, no blank lines, no text). Cert/key match verified via public-key derivation. Cert IDs published to the handoff artifact.

---

## 7. Parked Items (Google-gated, NOT blocking stages 3–5)

### 7.1 Model Armor (2 templates) — needed at Stage 7
- **Symptom:** `403 Read/Write access denied` from this VM; works from the user's local browser.
- **Root cause (two parts):**
  - **Enrollment:** the project needs Model Armor enrollment (Google account team). The 403 on the global endpoint is the gate.
  - **Network:** regional `.rep.googleapis.com` endpoints are **not** covered by the PSC `all-apis` bundle (`192.168.2.3`). They need a **dedicated PSC regional endpoint** (`gcloud network-connectivity regional-endpoints create ... --target-google-api=modelarmor.europe-west1.rep.googleapis.com`) plus a narrow private DNS zone for that exact hostname. This is a Stage 7 task.
- **Action:** raise Model Armor enrollment for `gclt-aicoe-dev-llm` (number `796737566809`, region europe-west1) with the Google account team.

### 7.2 Firestore CMEK — needed at Stage 6a
- **Symptom:** `429 maximum number of CMEK databases... request access`.
- **Root cause:** Firestore CMEK requires a Google allowlist (not an org policy).
- **Current state:** the session DB was created **without CMEK** (Google-managed encryption) so Stage 2 could complete.
- **Action:** request the allowlist via https://forms.gle/D3cB7xY6A44aVusY9 for `gclt-aicoe-dev-aihub-ui` (number `1042134323793`). **Once approved, CMEK cannot be added to the existing DB — it must be deleted and recreated** (re-add `cmek_config` to `gclt-aicoe-dev-aihub-ui.tf` then).

---

## 8. Tooling / Process Lessons

- **ADC expiry:** Colt's reauth (RAPT) policy expires ADC frequently. Use `gcloud auth application-default login --no-browser --force` (the `--force` is required — without it, stale credentials are reused).
- **Edit-tool corruption:** the file-edit tooling mangled HCL files with long underscore names (converted `gclt_aicoe_dev_ingress` → `gclt-aicoe_dev-ingress`). **Workaround:** edits to these files were made via Python scripts in the terminal, verified with `grep` + `terraform validate`.
- **`terraform fmt`** also caused a hyphen corruption once — verify with `git diff` after running it on these files.
- **policy-check.sh** had 2 false positives (grep matched check-block assertions and comment mentions) — fixed to anchor on real resource declarations.

---

## 9. Next Step — Stage 3 (Network)

**What it creates:** the VPC, 5 subnets, firewall rules, private DNS zones, and Shared VPC host + service-project attachment.

**Commands:**
```bash
cd terraform/3-network
terraform init -backend-config="bucket=aicoe-sharedwif-tfstate" -backend-config="prefix=3-network"
cp ../1-org.auto.tfvars.json .
terraform plan -var-file="../envs/dev/terraform.tfvars" -var-file="../envs/dev/stages/3-network.tfvars" -out=tfplan
# review, then apply
```

**Pre-flight check before applying:** the plan must show the 5 subnet CIDRs from the LLD (`10.110.73.0/24`, `192.168.4.0/23`, `192.168.6.0/26`, `192.168.6.128/28`, `192.168.6.144/28`), `private_ip_google_access = false` where set, one ACTIVE proxy-only subnet, and `egress-deny-all` at priority 65000.

**Known risk:** Shared VPC attachment needs `roles/compute.xpnAdmin` on the AI COE folder (`846301442455`). The folder's `owner` is held by groups `Ai-coe-admins@colt.net` / `aicoe-folder-ownerGroup@colt.net` — if the user is in one, owner covers xpnAdmin. If the attachment 403s, that role grant is the fix.

---

## 10. Handoff Artifacts (state of play)

| Artifact | Contents |
|---|---|
| `0-bootstrap.auto.tfvars.json` | state_bucket, deployer_emails, pool/provider names |
| `1-org.auto.tfvars.json` | project IDs + numbers, service_projects |
| `2-foundations.auto.tfvars.json` | KMS key IDs, SA emails (incl. `apigee_runtime_sa`, `worker_invoker_sa`, `apigee_llm_runtime_sa`), cert IDs, log bucket, BQ dataset, artifacts bucket |

All state in `gs://aicoe-sharedwif-tfstate/<stage>/`.
