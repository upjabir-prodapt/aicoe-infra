# 14 — Terraform structure: what the reference patterns do, and what we should do

**Revision R12.** A review of the repository layout against Google's two published landing-zone patterns, and the changes worth making.

---

## 1. What Google actually publishes

Two reference implementations, both stage-based, both differing from the layout I first built.

### Fabric FAST — `GoogleCloudPlatform/cloud-foundation-fabric`

<cite index="11-1">FAST implements a multi-stage deployment approach where each stage builds upon the outputs of previous stages, with a strict dependency chain 0 → 1 → 2 → 3. Stages also produce provider configuration files that enable authenticated access for downstream deployments.</cite> The tree is <cite index="11-1">`fast/stages/` containing `0-bootstrap`, `1-resman`, `2-networking`, `2-security`, `2-project-factory`, `3-gke-dev`, `3-data-platform`, alongside a `modules/` library.</cite>

The handoff mechanism is the part worth stealing. <cite index="4-1">Variables referring to resources managed by a previous stage are prepopulated via `0-bootstrap.auto.tfvars.json` and `1-resman.auto.tfvars.json` files linked or copied into the stage directory.</cite> Downstream stages read **generated variable files**, not upstream state.

<cite index="10-1">Auto-tfvars files contain outputs from preceding stages — folder identifiers, project identifiers — reducing manual effort in compiling variables.</cite>

### Cloud Foundation Toolkit — `terraform-google-modules/terraform-example-foundation`

<cite index="7-1">Several distinct Terraform projects, each in its own directory, applied separately but in sequence. Stage 0-bootstrap is executed manually; subsequent stages run through CI.</cite> Stages are `0-bootstrap`, `1-org`, `2-environments`, `3-networks-svpc`, `4-projects`, `5-app-infra`.

One structural point we do not currently follow: <cite index="7-1">it is a best practice to separate concerns by having two projects — one for Terraform state, one for the CI/CD tool. The seed project stores Terraform state and holds the service accounts that can create or modify infrastructure.</cite>

### The module philosophy both share

<cite index="20-1">Lean, composable, and close to the underlying provider resources. Modules are containers for all aspects related to usage of a resource type — a folder, a project, a VPC — including IAM, sub-resources and organisation policies. Unrelated resources should never be part of the same module, except in the two aggregation modules, project-factory and net-vpc-factory.</cite>

And <cite index="11-1">variable names and structures mirror the underlying `google_*` resources, making the mapping to API calls obvious.</cite>

---

## 2. Where the current layout falls short

| Issue | Consequence |
|---|---|
| **Layer names, not numbers** | `static`, `network`, `infra` do not convey order. A newcomer cannot tell that `static/apigee` must precede `network/psc` |
| **`terraform_remote_state` for handoff** | Every downstream stage needs read access to the upstream **state file**, which contains far more than the two values it wants. Both reference patterns pass generated tfvars instead |
| **No bootstrap stage** | The state bucket is created by hand. It is the one piece of the estate with no code and no audit trail |
| **No project factory** | Onboarding usecase number three means editing `.gitlab-ci.yml` and adding a stack directory by hand. With eight usecase projects planned, that does not hold |
| **`modules/project-baseline` mixes concerns** | APIs, service agents and service accounts in one module. Defensible, but against the stated boundary that unrelated resources do not share a module |
| **No environment abstraction** | Everything hardcoded to dev. Production means copying the tree |

---

## 3. The recommended structure

```
terraform/
├── 0-bootstrap/          MANUAL, once. State bucket, WIF pool, CI service accounts.
│                         Starts with local state, then migrates into the bucket it made.
├── 1-org/                Folder hierarchy, organisation policies, project factory.
│                         Creates all nine projects from YAML.
│   └── data/projects/    one YAML file per project
├── 2-foundations/        Per project: APIs, service agents, KMS, registries, secrets,
│                         Binary Authorization, Firestore, log bucket, sinks, audit config
├── 3-network/            VPC, subnets, firewall, DNS, Shared VPC attachment
├── 4-apigee/             Organisation, instance, environments.  SLOW, MANUAL GATE
├── 5-network-psc/        PSC endpoints — cannot exist until stage 4
├── 6-workloads/
│   ├── 6a-aihub-ui/      BFF backend service and NEG
│   ├── 6b-st/            usecase backend services, NEGs, run.invoker grants
│   └── 6c-ingress/       load balancer frontends — NEEDS 6a AND 6b
├── 7-apigee-runtime/     endpoint attachment, target servers, key value maps
├── modules/
└── envs/
    ├── dev/terraform.tfvars
    └── prod/terraform.tfvars
```

**Numbers, not names.** The order is in the directory listing. `5-network-psc` obviously follows `4-apigee`, which is the non-obvious dependency that most needs signposting.

**Two network stages, numbered apart.** `3-network` and `5-network-psc` are separated by the Apigee stage between them, which is exactly the point — the split has a reason and the numbering shows it.

---

## 4. The handoff change, and why it matters

Today: `infra/ingress` opens the state files of `infra/st` and `infra/aihub-ui`, and its service account needs read on those objects.

Recommended: each stage publishes its outputs as JSON; the next stage consumes them as `.auto.tfvars.json`. Terraform loads any file matching that pattern automatically, so downstream stages simply declare ordinary variables.

In GitLab this is native — no bucket paths, no extra IAM:

```yaml
# upstream job
script:
  - terraform output -json | jq 'map_values(.value)' > ${STAGE}.auto.tfvars.json
artifacts:
  paths: [ "${STAGE}.auto.tfvars.json" ]

# downstream job
needs:
  - job: "3-network"
    artifacts: true      # the file lands in the workspace
```

Three benefits:

1. **No cross-stack state access.** A stage's service account needs its own state and nothing else. Today `6c-ingress` can read everything in two other stacks' state, including anything sensitive that happens to be there.
2. **The contract is explicit.** A stage declares `variable "vpc_self_link"`. What it consumes is visible in `variables.tf` rather than buried in a `data` block.
3. **Stages become testable in isolation.** Supply a tfvars file by hand and plan without any upstream stage existing.

---

## 5. The project factory

Nine projects today, seventeen or more once the other usecases arrive. Each currently means a directory and a pipeline job.

The factory pattern replaces both with a YAML file:

```yaml
# 1-org/data/projects/gclt-aicoe-dev-st.yaml
parent: folders/dev-usecases
billing_account: ${billing_account}
services:
  - run.googleapis.com
  - artifactregistry.googleapis.com
  - aiplatform.googleapis.com
shared_vpc_service_config:
  host_project: gclt-aicoe-dev-network
labels:
  environment: dev
  usecase: sales-translation
  cost-centre: aicoe
```

<cite index="16-1">Filesystem directories containing project definitions in YAML are read by the factory and iterated over.</cite> Onboarding then becomes a merge request adding one file, reviewed by the platform team — which is also the governance gate you want.

**One caveat worth respecting.** <cite index="16-1">This approach must be used with caution and is best adopted for stable scenarios, as problems in the filesystem hierarchy definitions might result in the project files not being read and the resources being deleted by Terraform.</cite> A YAML file accidentally deleted or moved reads as "destroy this project". Mitigate with `prevent_destroy` on the projects and a pipeline check that fails if the file count drops unexpectedly.

---

## 6. Labels — currently missing entirely

Cost attribution by business unit is a core platform requirement, and nothing in the current code labels anything. Every project and every billable resource should carry `environment`, `usecase`, `cost-centre` and `owner` at minimum. The factory is the natural place to enforce it, since a YAML file without the required labels can be rejected at plan time.

---

## 7. What not to adopt

**Terragrunt.** It solves the repetition problem, but adds a dependency, a second language and a hiring constraint. The tfvars handoff plus a project factory addresses the same problem inside Terraform.

**FAST wholesale.** It is a complete organisation bootstrap and assumes it owns the resource hierarchy from the root. Colt already has an organisation, folders and policies. Borrow the patterns — numbered stages, tfvars handoff, project factory — not the framework.

**Terraform Stacks.** Genuinely addresses multi-environment deployment, but it is HCP Terraform. You are on GitLab with GCS state.

---

## 8. Migration order

The changes are independent and can land separately.

| # | Change | Effort | Why now |
|---|---|---|---|
| 1 | Delete the fake `check` block in `infra/st` | Minutes | It advertises a control that does not exist |
| 2 | Add policy-as-code to the validate stage | Hours | Your invariants — no `allUsers`, no public ingress, CMEK everywhere — are enforced nowhere |
| 3 | Renumber the stages | Hours | Cheapest while there are fourteen stacks and no history |
| 4 | Switch to tfvars handoff | A day | Removes cross-stack state access |
| 5 | Add `0-bootstrap` | A day | The state bucket is the only uncoded resource |
| 6 | Add labels | Hours | Required for the cost attribution the platform exists to provide |
| 7 | Project factory | Two days | Do it before the second usecase project, not after |
| 8 | Environment abstraction | A day | Do it before production exists |

Items 1 and 2 are security-relevant. Item 3 gets more expensive with every stack added. Items 7 and 8 get more expensive with every project and every environment.
