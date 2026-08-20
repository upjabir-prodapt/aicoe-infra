# Project Progress

## Deploy Status (Current State of Play)

| Stage | Purpose | Status |
|---|---|---|
| **0-bootstrap** | State bucket, CMEK key, 8 deployer SAs, GitLab OIDC pool | ✅ **COMPLETE** |
| **1-org** | Read-only reference of project inventory | ✅ **COMPLETE** |
| **2-foundations** | APIs, service agents, KMS, logging, firestore, secrets, certs | ✅ **COMPLETE** (Migrated to `europe-west3`, renamed KMS keyrings to `-ew3`) |
| **3-network** | VPC, 5 subnets, firewall rules, private DNS zones, Shared VPC | ✅ **COMPLETE** (Migrated to `europe-west3`, subnets suffix `_ew3`) |
| **4-apigee** | Apigee Org, Instance, Base + Intermediate environments | ✅ **COMPLETE** (Co-located in Frankfurt `europe-west3` due to Org Policy) |
| **5-network-psc** | Apigee & Google APIs PSC endpoints | ✅ **COMPLETE** (Routable IP alignment, Model Armor regional endpoint + DNS zone) |
| **6-workloads** | BFF workload NEG, use case backends, private load balancers | ⬜ Pending |
| **7-apigee-runtime** | Southbound endpoints, KVM containers, Model Armor templates | ⬜ Pending (To be augmented with Model Armor templates moved from Stage 2) |

## What Works
- **Stage 0 & 1:** Fully applied and state saved.
- **Stage 2:** Core APIs, deterministic service agent emails, logging sinks, and Certificate Manager certs exist.
- **Stage 3 Network:** VPC (`gclt-aicoe-dev-vpc`), subnets, firewall rules, private DNS zones/records, Shared VPC host enablement and service project attachments are fully complete.
- **Stage 4 Apigee:** Apigee Organisation, environments, and physical instance fully provisioned (in Frankfurt `europe-west3` due to strict Organization Policy locations constraint).

## What is Left to Build
- Stage 6a/6b/6c workload backends and load balancers.
- Stage 7 Apigee Runtime config and Model Armor templates.

## Known Issues & Blockers
- **Stage 6 Workloads:** Cloud Run services must be deployed by the application teams *prior* to applying Stage 6a/6b, as the serverless NEGs and `run.invoker` data blocks query them by name.
