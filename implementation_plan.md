# Implementation Plan

[Overview]
Continue the AI CoE Dev Platform deployment from Stage 3 (Network) through Stage 7 (Apigee Runtime), incorporating a code redesign to move Model Armor template creation out of Stage 2 and into Stage 7, where the regional PSC endpoint will already exist, plus a one-time Stage 2 re-apply to enable the `networkconnectivity.googleapis.com` API needed by Stage 5.

The AI CoE Dev Platform migration paused after successfully completing Stage 2 (Foundations). The stages are applied in strict sequential order (0→1→2→3→4→5→6a/6b→6c→7), and outputs from each stage are passed as `.auto.tfvars.json` artifacts to downstream stages. The critical architectural problem is that Model Armor templates were created in Stage 2 using a global endpoint workaround (`model_armor_custom_endpoint = "https://modelarmor.googleapis.com/v1beta/"` in `providers.tf`), but they actually require the regional endpoint `modelarmor.europe-west1.rep.googleapis.com`. The regional PSC endpoint for Model Armor can only be created in Stage 5 (after the VPC exists in Stage 3). Since we cannot go back and re-apply Stage 2 *after* Stage 5 without breaking the sequential build order, the correct solution is to **move the Model Armor template resources out of Stage 2 and into Stage 7**, which is the last stage and runs after Stage 5 has established the regional PSC endpoint and DNS.

The `2-foundations.auto.tfvars.json` artifact already shows `"gclt_aicoe_dev_llm_template_ids": {"default": null, "strict": null}` — confirming the templates were never successfully created in Stage 2. This makes the move clean: we remove the dead resources from Stage 2 and add them to Stage 7 where they will succeed.

Separately, live verification against GCP (`gcloud services list --enabled --project=gclt-aicoe-dev-network`) confirmed `networkconnectivity.googleapis.com` is **not enabled** on the network project. This API is required in Stage 5 for both the pre-existing Vector Search `google_network_connectivity_service_connection_policy` resource and the new Model Armor `google_network_connectivity_regional_endpoint` resource. Per user direction, this is fixed by adding the API to Stage 2's `gclt-aicoe-dev-network.tf` and re-applying Stage 2 now — before Stage 3 is applied — which is safe because Stage 2 is upstream of Stage 3/4/5 in the sequence and re-applying it now does not violate the "no going back" rule (we are not going back after later stages have run; we are completing Stage 2's scope before moving forward).

[Types]
No new type definitions are required; existing Terraform HCL variable and resource types are used throughout.

The `google_model_armor_template` resource type (from `google-beta` provider) will be moved from Stage 2 to Stage 7. Stage 7 will need a `google-beta` provider block added.

[Files]
Four Terraform files require modification, plus one tfvars entry addition.

Detailed breakdown:
- **`terraform/2-foundations/gclt-aicoe-dev-network.tf`** (MODIFY): Add `"networkconnectivity.googleapis.com"` to the `services` list in `module.gclt_aicoe_dev_network_baseline`. Required by Stage 5's Vector Search service connection policy and the new Model Armor regional endpoint.
- **`terraform/2-foundations/gclt-aicoe-dev-llm.tf`** (MODIFY): Remove the two `google_model_armor_template` resources and their output block. Keep all other resources (IAM grants, project baseline, breakglass SA).
- **`terraform/2-foundations/providers.tf`** (MODIFY): Remove the `provider "google-beta"` block with `model_armor_custom_endpoint` override entirely, since no `google-beta` resources remain in Stage 2.
- **`terraform/5-network-psc/main.tf`** (MODIFY): Add the Model Armor regional PSC endpoint infrastructure:
  - `google_compute_address.modelarmor_endpoint` — static internal IP (e.g. `192.168.6.165`) in the `internal` subnet.
  - `google_network_connectivity_regional_endpoint.modelarmor` — regional endpoint targeting `modelarmor.europe-west1.rep.googleapis.com`.
  - `google_dns_managed_zone.modelarmor` — private DNS zone for `modelarmor.europe-west1.rep.googleapis.com.` scoped to the VPC.
  - `google_dns_record_set.modelarmor` — A record pointing to the new static IP.
  - Output: `modelarmor_endpoint_ip` for reference.
- **`terraform/7-apigee-runtime/main.tf`** (MODIFY): Add the two `google_model_armor_template` resources (moved from Stage 2), a `google-beta` provider block pointing to the regional endpoint via the private DNS hostname, and the `gclt_aicoe_dev_llm_template_ids` output. Add `variable "gclt_aicoe_dev_llm_project_id"` declaration (region variable already exists).
- **`terraform/envs/dev/stages/7-apigee-runtime.tfvars`** (MODIFY): Add `gclt_aicoe_dev_llm_project_id = "gclt-aicoe-dev-llm"`.

[Functions]
No application-level functions are modified; all changes are Terraform resource declarations.

Detailed breakdown:
- Modified in Stage 2: `module.gclt_aicoe_dev_network_baseline` services list gains `networkconnectivity.googleapis.com`.
- Removed from Stage 2: `google_model_armor_template.gclt_aicoe_dev_llm_default`, `google_model_armor_template.gclt_aicoe_dev_llm_strict`, `output.gclt_aicoe_dev_llm_template_ids`.
- Added to Stage 5: `google_compute_address.modelarmor_endpoint`, `google_network_connectivity_regional_endpoint.modelarmor`, `google_dns_managed_zone.modelarmor`, `google_dns_record_set.modelarmor`.
- Added to Stage 7: `google_model_armor_template.aicoe_default`, `google_model_armor_template.aicoe_strict`, `output.gclt_aicoe_dev_llm_template_ids`, `provider "google-beta"` block.

[Classes]
No class modifications required; this is a Terraform infrastructure deployment.

Detailed breakdown:
- The `google-beta` provider block moves from Stage 2 (`providers.tf`) to Stage 7 (`main.tf`), and its `model_armor_custom_endpoint` changes from the global endpoint to the regional endpoint hostname `https://modelarmor.europe-west1.rep.googleapis.com/`.

[Dependencies]
The dependency chain between stages is strictly sequential and must be respected.

Detailed breakdown:
- **Stage 2 (re-applied)** → enables `networkconnectivity.googleapis.com` on the network project, needed by **Stage 5**.
- **Stage 3** → outputs `vpc_self_link`, `internal_subnet_self_link`, `private_zone_name` → consumed by **Stage 5**.
- **Stage 4** → outputs `instance_service_attachment`, `org_id` → consumed by **Stage 5** and **Stage 7**.
- **Stage 5** → creates Model Armor regional PSC endpoint + DNS → enables **Stage 7** to reach `modelarmor.europe-west1.rep.googleapis.com` via private DNS.
- **Stage 6c** → outputs `backend_service_attachment_id` → consumed by **Stage 7**.
- **Stage 7** → now also creates Model Armor templates using the regional endpoint (which resolves correctly via Stage 5's DNS zone).
- Stage 7 needs `gclt_aicoe_dev_llm_project_id`, sourced from `1-org.auto.tfvars.json` or set directly in its per-stage tfvars.

[Implementation Order]
Execute stages sequentially, with code changes made before the affected stage is applied.

1. **Code change:** Add `"networkconnectivity.googleapis.com"` to `terraform/2-foundations/gclt-aicoe-dev-network.tf`'s services list.
2. **Re-apply Stage 2 (Foundations):** `cd terraform/2-foundations && terraform init -reconfigure ... && terraform plan ... -out=tfplan && terraform apply tfplan`. Verify only the network project's API enablement changes (no other resources should show a diff).
3. **Apply Stage 3 (Network):** Apply the already-validated plan: `cd terraform/3-network && terraform apply tfplan`.
4. **Handle Shared VPC risk:** If the Shared VPC attachment fails with 403, grant `roles/compute.xpnAdmin` on the AI COE folder (`846301442455`) and re-apply. (Live IAM check shows `Ai-coe-admins@colt.net` / `aicoe-folder-ownerGroup@colt.net` hold folder `owner`, which should cover this.)
5. **Export Stage 3 outputs:** `terraform output -json | jq 'map_values(.value)' > ../vars-handoff/3-network.auto.tfvars.json`.
6. **Apply Stage 4 (Apigee):** Init, plan, and apply. Allow 30–60 minutes. Export outputs to `../vars-handoff/4-apigee.auto.tfvars.json`.
7. **Code change (before Stage 5 apply):** Modify `terraform/5-network-psc/main.tf` to add the Model Armor regional PSC endpoint resources (static IP `192.168.6.165`, `google_network_connectivity_regional_endpoint`, private DNS zone for `modelarmor.europe-west1.rep.googleapis.com.`, and A record).
8. **Apply Stage 5 (Network PSC):** Init, plan (verify Apigee PSC + Model Armor PSC + Vector Search policy), and apply. Export outputs to `../vars-handoff/5-network-psc.auto.tfvars.json`.
9. **Apply Stages 6a and 6b (Workloads):** These require Cloud Run services to be deployed first. Apply once app images are available.
10. **Apply Stage 6c (Ingress):** Requires 6a, 6b outputs and both TLS certificates. Apply and export outputs.
11. **Code change (before Stage 7 apply):**
    - Remove `google_model_armor_template` resources and their output from `terraform/2-foundations/gclt-aicoe-dev-llm.tf`.
    - Remove the `provider "google-beta"` block from `terraform/2-foundations/providers.tf`.
    - Add `provider "google-beta"` block to `terraform/7-apigee-runtime/main.tf` with `model_armor_custom_endpoint = "https://modelarmor.europe-west1.rep.googleapis.com/"`.
    - Add the two `google_model_armor_template` resources and their output to `terraform/7-apigee-runtime/main.tf`.
    - Add `variable "gclt_aicoe_dev_llm_project_id"` to Stage 7.
    - Add `gclt_aicoe_dev_llm_project_id = "gclt-aicoe-dev-llm"` to `terraform/envs/dev/stages/7-apigee-runtime.tfvars`.
    - **Note:** since Stage 2 will show a diff (removed Model Armor resources) after this change, re-apply Stage 2 one final time to destroy the (already-null) Model Armor template resources cleanly from state.
12. **Apply Stage 7 (Apigee Runtime):** Init, plan (verify endpoint attachment + KVM containers + Model Armor templates), and apply.
13. **Update `docs/BUILD-LOG.md`:** Record completion of Stages 2 (re-applied), 3, 4, 5, 6, 7, the Model Armor architectural redesign, and any blockers encountered.

task_progress:
- [ ] Add networkconnectivity API to Stage 2 network project and re-apply Stage 2
- [ ] Apply Stage 3 (Network) and export outputs
- [ ] Apply Stage 4 (Apigee) and export outputs
- [ ] Modify Stage 5 to add Model Armor regional PSC endpoint + DNS
- [ ] Apply Stage 5 (Network PSC) and export outputs
- [ ] Apply Stages 6a/6b (Workloads) once Cloud Run services are available
- [ ] Apply Stage 6c (Ingress)
- [ ] Move Model Armor templates from Stage 2 to Stage 7; remove Stage 2's google-beta provider override
- [ ] Re-apply Stage 2 to cleanly remove Model Armor resources from state
- [ ] Apply Stage 7 (Apigee Runtime) including Model Armor templates
- [ ] Update docs/BUILD-LOG.md with final status
