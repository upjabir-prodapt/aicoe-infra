## Brief overview
Rules governing how Terraform `apply` operations are executed within this repository's staged deployment model (see `terraform-staged-deployment.md` for stage ordering rules). These rules control the operational discipline around running `terraform plan`/`apply` for a single stage at a time.

## One stage at a time
- Never run `terraform apply` (or plan+apply) for more than one numbered stage in the same work session step. Complete and verify one stage fully before moving to the next.
- Stage order must follow the sequence defined in `terraform-staged-deployment.md`: `0-bootstrap` → `1-org` → `2-foundations` → `3-network` → `4-apigee` → `5-network-psc` → `6a`/`6b` → `6c` → `7-apigee-runtime`.
- Do not skip ahead to a later stage even if its config already exists, unless all earlier stages have been successfully applied.

## Understand the stage before acting
- Before running `terraform plan` or `terraform apply` for a stage, first review that stage's configuration (`main.tf`/`*.tf` files, variables, and its position in the `0-bootstrap` → `7-apigee-runtime` sequence) to understand what it does.
- State to the user what you are about to do in this stage (in plain terms) before running any Terraform command against it — not just as part of the pre-apply summary, but as the first step of engaging with a stage at all (including for `plan`-only work).

## Cross-stage variable handling
- Before planning/applying a stage, check whether it consumes any values that originate from an upstream stage (per the `.auto.tfvars.json` handoff pattern in `terraform-staged-deployment.md`).
- If a needed value comes from a previous stage's output, copy it into the current stage's `.auto.tfvars.json` / `.tfvars` file rather than referencing the other stage's state or files directly. Never use `terraform_remote_state` for this.
- Verify that every variable referenced in the stage's `.tf` files has a corresponding declaration (`variable` block) and an assigned value (via tfvars, defaults, or CLI) — do not leave a variable used without it being declared, and call out to the user any variable that is declared but not yet populated.

## Code change explanation requirement
- If accomplishing a stage requires making code changes (new/modified `.tf` files, variables, resources, tfvars entries), explain to the user what change is being made and why before making it — do not silently edit configuration files as a side effect of getting a stage to apply.

## Plan before apply
- Always run `terraform plan` for the stage first and review/show the resulting diff before running `terraform apply`. Do not go straight to `apply` on the basis of a prose description alone.
- If the plan output reveals unexpected changes (e.g. unrelated resource drift, destroys not discussed), pause and clarify with the user before applying.

## Pre-apply summary requirement
- Before running `terraform apply` for a stage, present the user with a short summary covering:
  - What the stage is trying to accomplish (its purpose in the overall platform).
  - The specific resource(s)/service(s)/variable(s) that will be created or changed (e.g. resource type and name, or the tfvars keys being consumed).
  - Why this resource/change is needed at this point in the sequence (its dependency or design rationale).
- This summary must be given even for straightforward or previously-discussed changes; do not apply silently.

## Explicit go-ahead confirmation
- Even where tool-level approval exists, explicitly ask the user for a clear go-ahead ("yes, apply") after presenting the pre-apply summary and plan diff, before running `terraform apply`. Do not treat silence or unrelated approval as consent to apply.

## Apply execution and waiting
- After starting `terraform apply`, wait for the command to fully finish (success or failure) before taking any further action. Terraform applies in this project can take a noticeable amount of time (e.g. network, Apigee, PSC resources) — do not treat a lack of immediate output as failure or move on prematurely.
- Do not run other Terraform commands (plan/apply/destroy) concurrently against the same stage while an apply is in progress.

## Error handling before proceeding
- If a `terraform apply` fails or errors, stop and troubleshoot the root cause in the current stage before doing anything else — do not proceed to the next stage with an unresolved failure.
- After identifying a fix, re-plan and re-apply the same stage, and confirm success, before moving on.
- Only proceed to the next stage once the current stage's apply has completed successfully with no outstanding errors.

## Post-apply verification
- After a successful apply, don't rely solely on exit code 0 — briefly verify the outcome (e.g. inspect `terraform output` or relevant state/resource) and note the confirmed result to the user.
- Confirm the stage's exported `<stage>.auto.tfvars.json` artifact was (re)generated/updated correctly, since this is how the repo hands off outputs to the next stage. Do not consider a stage complete until this handoff artifact is verified.
- **Rule for Stage Deployment Documentation:** After each successful apply of any stage, you must document the exact Terraform code and execution commands (including copying of OIDC/Stage outputs, initialization, plan, apply, and output exports) in `/home/jabir_mohammed_colt_net/AICOE-Terraform/docs/16-terraform-staged-deployment.md` under its respective section.

## Destroy and rollback caution
- `terraform destroy` or removal of resources from a stage follows the same discipline as apply: one stage at a time, a pre-action summary (what/why), explicit user go-ahead, waiting for completion, and troubleshooting any errors before proceeding.
- Before destroying or rolling back a stage, consider and call out impacts on downstream stages that consume its `.auto.tfvars.json` outputs.
