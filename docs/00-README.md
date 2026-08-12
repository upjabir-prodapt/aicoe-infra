# AI CoE dev platform — design set

**Revision R13.** Greenfield internal AI platform on Google Cloud: nine projects, one Shared VPC, Backend-for-Frontend, Apigee as both API gateway and AI gateway, europe-west1 only.

---

> **The design of record is `LLD - AICOE GCP Infrastructure v2.0.2`, one directory up.** It covers Sandbox and Development, and it is what the Terraform is built against. The documents below remain useful — they carry the reasoning, the validation evidence and the console build steps — but where any of them disagrees with the LLD, the LLD wins. Addresses here follow the LLD's Development plan: the unrouted range is `192.168.4.0/22`.

## Current documents

| # | Document | What it is |
|---|---|---|
| **11** | `11-reconciled-architecture.md` | The reconciled architecture note. BFF, identity model, Entra configuration, session design, rate limiting, southbound path, costs, open items |
| **09** | `09-implementation-runbook-console.md` | **The build.** 25 parts, console clicks and exact values, beginner-friendly. Everything except writing the Cloud Run services |
| **10** | `10-validation-log.md` | Every load-bearing claim checked against Google's documentation. 15 verdicts recorded, with what changed as a result |
| **03** | `03-spike-and-verification-plan.md` | 13 spikes in dependency order, 6 desk checks, kill criteria, 8-week sequence. Nine earlier spikes closed and listed so nobody re-runs them |
| **04** | `04-gap-register.md` | 25 open gaps, prioritised into before-Terraform, before-build, before-go-live. Fourteen earlier items closed and listed |
| **05** | `05-logging-design.md` | 400-day retention, central bucket, three sinks, the double-billing trap. Unaffected by the architecture change |
| **08** | `08-llm-gateway.md` | Central Vertex AI project, token quotas, Model Armor, first-party sample mapping |
| **12** | `12-status-register.md` | **One view of everything.** 21 settled, 13 corrected, 9 unverified, 23 open — with what blocks what |
| **13** | `13-session-lifecycle-and-limits.md` | Logout, session rotation, refresh serialisation, fail-closed behaviour, and the platform limits inventory |

**Word document:** `AI-CoE-Dev-Platform-Implementation-Runbook.docx` — the runbook, 74 pages. In Word, right-click the Contents list and choose Update Field.

## Repository layout

```
.
├── AI-CoE-Dev-Platform-Implementation-Runbook.docx    the runbook, 77 pages
│
├── docs/                       design set, 10 documents
│   ├── 00-README.md            this file
│   ├── 11-reconciled-architecture.md    the design — read first
│   ├── 09-implementation-runbook-console.md
│   ├── 12-status-register.md   settled · corrected · unverified · open
│   ├── 13-session-lifecycle-and-limits.md
│   ├── 10-validation-log.md    claims checked against Google docs
│   ├── 03, 04                  spikes and gaps
│   ├── 05, 08                  logging, LLM gateway
│   └── superseded/             10 earlier documents, banner-marked
│
├── diagrams/                   PNG and SVG
│   ├── aicoe-dev-topology
│   ├── aicoe-dev-auth-flow
│   └── aicoe-dev-llm-gateway
│
└── terraform/               numbered stages, Fabric FAST style
    ├── .gitlab-ci.yml        the dependency DAG, artifact handoff
    ├── README.md
    ├── 0-bootstrap/          manual once — state bucket, WIF, CI identities
    ├── 1-org/                folders, policies, project factory (YAML)
    ├── 2-foundations/        APIs, agents, KMS, registries, logging
    ├── 3-network/            VPC, subnets, firewall, DNS
    ├── 4-apigee/             org, instance, environments — manual gate
    ├── 5-network-psc/        PSC endpoints, needs stage 4
    ├── 6-workloads/          6a/6b/6c, each named for its project
    ├── 7-apigee-runtime/     endpoint attachment, target servers
    ├── ci/                   job templates, policy checks
    ├── modules/
    └── envs/dev · envs/prod
```

## Diagrams

| File | Shows |
|---|---|
| `aicoe-dev-topology.png` / `.svg` | Full platform topology at R10, every address annotated |
| `aicoe-dev-auth-flow.png` / `.svg` | Authentication, session and token flow — 27 numbered steps from first visit to backend invocation |
| `aicoe-dev-llm-gateway.png` / `.svg` | East-west inference path and policy chain |

## `superseded/`

Ten earlier documents, each with a banner explaining why. **Do not build from them** — the architecture changed twice after they were written.

---

## The architecture in six sentences

Colt users reach one address, `10.110.73.20`, through ZPA. An internal load balancer with IAP sits in front of a Cloud Run **Backend-for-Frontend**, which serves the interface and is the OAuth client — the browser holds only an opaque session cookie, never a token. The BFF calls Apigee server-side at an internal service endpoint, where **per-user rate limiting** is enforced on the Entra `oid` and entitlement is checked against **App Roles**. Apigee reaches the backend Cloud Run services over Private Service Connect, authenticating to **IAP enabled directly on those services**. Both backends call Vertex AI through a second Apigee environment that meters token spend per user. Everything except that one address sits in `192.168.4.0/22`, which has no route from the Colt network.

## Decisions that are settled

| Decision | Why |
|---|---|
| Apigee non-peered, Private Service Connect throughout | Peering is non-transitive, so other usecase VPCs could never consume the gateway. Immutable after org creation |
| Backend-for-Frontend rather than a browser-side token | Makes single sign-on independent of browser cookie policy, and removes Apigee from the browser's reach entirely |
| Entra App Roles for entitlement, Security Groups for administration | Readable `roles` array in policy, no group GUIDs, no overage cliff. The service desk manages membership without touching an app registration |
| Per-user quota keyed on `oid`; department is a reporting dimension | The budget is per user. Keying on department would let one person exhaust a colleague's allowance |
| One IAP, at the front door, authenticating people. The backend hop uses Cloud Run IAM with `run.invoker` scoped to the Apigee service account | One mechanism per boundary. IAP proves a person, Apigee decides what they may do, Cloud Run IAM proves the machine |
| `int` environment Base, `llm` environment Intermediate | Both LLM token policies are Extensible and deploy only to intermediate or comprehensive environments |
| Firestore for sessions, not Redis | Memorystore basic tier uses Private Service Access, which creates a VPC peering on the Shared VPC host |
| VPC Service Controls deferred | Compensating controls and the accepted residual risk recorded in `11` |

## What is still open

| # | Item | Blocks |
|---|---|---|
| 1 | **Spike S1**, three arms — Cloud Run IAM through the load balancer (the design), IAP on backend services (fallback), and whether IAP works on an internal load balancer at all (the front door) | Arm 1 decides the backend path, arm 3 decides the front door |
| 2 | **CSRF protection design** for the BFF | Required, not optional. New exposure introduced by cookie-based sessions |
| 3 | Silent token acquisition producing no visible prompt in Colt's browser estate | The single-login requirement |
| 4 | Cloud Armor on a regional internal load balancer | Whether WAF coverage can be claimed |
| 5 | Apigee cost modelling — Extensible per-call rate against expected AI volume | Whether the AI gateway stays in Apigee |
| 6 | Refresh-stampede handling, session read latency | Build detail |
| 7 | Certificate ownership and DNS-01 automation | Go-live. Expiry is a total outage |
| 8 | New-usecase onboarding runbook | The platform's actual product |

Items 1 and 4 are both load-balancer questions answerable in a scratch project in a day. **Nothing on this list blocks Parts 1 to 17 of the runbook** — org policies, APIs, KMS, logging, network, Shared VPC, registries, Firestore and the LLM project are unaffected.

## The step that is easy to defer and should not be

Runbook §18.4: remove `roles/aiplatform.user` from every workload service account, leaving it only on `apigee-llm-runtime`. Until that is done, every control in the AI gateway is advisory and any service can bypass it. Test 14 in Part 24 is how you prove it.
