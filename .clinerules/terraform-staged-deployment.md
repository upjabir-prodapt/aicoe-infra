## Brief overview
Project-specific rules for the AI CoE GCP Terraform platform. The repository deploys a greenfield AI platform in numbered, strictly sequential Terraform stages (0-bootstrap → 7-apigee-runtime), with each stage's outputs handed off to the next as `.auto.tfvars.json` files rather than via `terraform_remote_state`.

## Design of record and precedence
- `LLD - AICOE GCP Infrastructure v2.0.2` (repo root) is the design of record. Where any doc in `docs/` disagrees with it, the LLD wins.
- `docs/00-README.md` is the index; read it to find which numbered doc governs a given topic before making architectural changes.
- Addresses follow the LLD's Development plan: unrouted range `192.168.4.0/22`.

## Stage architecture rules
- Stages are numbered and must be applied strictly in order: `0-bootstrap` → `1-org` → `2-foundations` → `3-network` → `4-apigee` → `5-network-psc` → `6a`/`6b` → `6c` → `7-apigee-runtime`.
- Never introduce cross-stage `terraform_remote_state` data sources. Each stage consumes only ordinary Terraform variables populated from the upstream stage's exported `<stage>.auto.tfvars.json` artifact.
- When a resource's dependency (e.g. a regional PSC endpoint, a VPC) does not yet exist at the stage where it was originally placed, move the resource to the earliest stage where its dependency is satisfied, rather than working around it with global-endpoint hacks or manual state surgery.
- Before changing resource placement across stages, verify in the relevant `.auto.tfvars.json` artifact whether the original resource ever successfully applied (e.g. null/empty output values indicate it never did), which makes the move "clean" with nothing to destroy.

## Documenting infrastructure changes
- Any structural or architectural redesign to the Terraform stages must be reflected in `implementation_plan.md` using its existing section structure ([Overview], [Types], [Files], [Functions], [Classes], [Dependencies], [Implementation Order]) before implementation.
- After completing a set of staged applies, record what was completed, the architectural change made, and any blockers encountered in `docs/BUILD-LOG.md`.
- Keep `docs/14-terraform-structure-decision.md` in mind as the rationale reference for the numbered-stage / tfvars-handoff / project-factory pattern; do not silently reintroduce patterns it explicitly rejects (Terragrunt, full FAST adoption, Terraform Stacks, remote-state handoff).

## Provider and resource conventions
- `google-beta` provider blocks should only be declared in the stage that actually contains `google-beta`-only resources; remove them from stages that no longer need them rather than leaving unused provider blocks.
- When pointing at a regional PSC-backed API endpoint (e.g. Model Armor), use the actual regional hostname (`<service>.<region>.rep.googleapis.com`) resolved via a private DNS zone created in the stage responsible for PSC endpoints — do not rely on global endpoint overrides as a permanent solution.
