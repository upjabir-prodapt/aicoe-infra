# 04 — Gap register

**Revision R12.** Rewritten for the Backend-for-Frontend architecture. What the design set is still missing, prioritised.

Fourteen items from earlier revisions are closed and listed in §6, so nobody works on them twice.

---

## 1. Blocking — resolve before Terraform

| # | Gap | Why it blocks |
|---|---|---|
| **G1** | **Spike S1** — does a load balancer without IAP forward to a Cloud Run service with IAP enabled directly? | Determines whether the Backend load balancer, `192.168.6.145`, the published service and the `192.168.6.128/28` NAT subnet exist at all. That in turn determines the IPAM request |
| **G2** | **CSRF protection design** for the BFF | Not optional and not a test. The cookie is now sent automatically, so the exposure is real. Must be specified, not discovered |
| **G3** | **Certificate ownership and DNS-01 automation** | A publicly issued certificate on a privately resolved name needs control of the public `colt.net` zone. Expiry is a total outage and this is the most common self-inflicted failure in designs of this shape |

---

## 2. Functional gaps

| # | Gap | Detail |
|---|---|---|
| **G4** | **Cloud Armor on a regional internal load balancer** — asserted throughout, never verified | Regional backend security policies for `INTERNAL_MANAGED` load balancers have different support and rule capabilities from external ones, and edge policies are external-only. Verify before claiming WAF coverage in a signed-off document. Compensating control: only ZPA reaches `.20` |
| **G5** | **Logout, everywhere** | Clearing the BFF session is easy. Also needed: clearing the IAP session, optionally RP-initiated logout at Entra, and revoking the refresh token. A "logout" that leaves the IAP session live means the next visitor to that browser is silently signed in as the previous user |
| **G6** | **Session fixation and rotation** | The session id must be rotated on authentication and on any privilege change. Not currently specified |
| **G7** | **Model output rendering** | If model output is rendered as HTML or Markdown in the interface it is a cross-site-scripting vector. Sanitise on render |
| **G8** | **Agent tool-call authorisation** | If the Sales Agent gains tool-calling, each call must be authorised in the **user's** context against the user's entitlements, not the agent's. Otherwise the agent is a confused deputy holding the union of everyone's permissions. Cheap now, expensive to retrofit |

---

## 3. Operational gaps

| # | Gap | Detail |
|---|---|---|
| **G9** | **No limits and quotas inventory** | Apigee proxy deployment units per instance, KVM and cache entry sizes, message size limits, Vertex AI queries and tokens per minute, Model Armor's 1,200 queries per minute, Cloud Run instance quotas, Cloud Tasks dispatch rates, Firestore write limits, PSC endpoints per VPC. Several bite at integration time. A one-page table prevents surprises |
| **G10** | **New-usecase onboarding runbook** | This is the platform's actual product. A new usecase needs a project, Shared VPC attachment, a `maxScale` allocation from the 127-instance ceiling, an Apigee developer app and product tier, Entra App Role and group, IAM, log sink, Artifact Registry and a Binary Authorization policy. Write it once or every onboarding is bespoke |
| **G11** | **Cost attribution is designed, chargeback is not** | Token counts per user and department exist. Nothing says who produces the monthly report, what the unit rate is, or who reconciles it against the Vertex bill. Also missing: budget alerts per project, and an alert on Extensible-proxy call volume — the line item most likely to surprise |
| **G12** | **Latency budget** | A user request now traverses ZPA, load balancer, IAP, BFF, a Firestore read, Apigee, PSC, a second load balancer, IAP again, then the service — and for AI, Apigee and Vertex on top. Google notes explicitly that IAP increases latency, and you pay it twice. Set a target and measure it, rather than discovering it in user acceptance testing |
| **G13** | **Firestore is now a hard dependency on the request path** | Backup, restore and a tested failure mode. Session loss signs everybody out, which is survivable; job-record loss breaks in-flight translations, which is not |
| **G14** | **No performance or load test** | Beyond the individual spikes. In particular the interaction of session reads, quota counters and IAP under concurrency |

---

## 4. Security and compliance

| # | Gap | Detail |
|---|---|---|
| **G15** | **Container hardening unspecified** | Non-root user, read-only root filesystem, minimal or distroless base, no shell. Dependency and secret scanning in CI. Secrets referenced from Secret Manager, never injected as environment variables |
| **G16** | **Security headers on the BFF** | Content Security Policy, HSTS, `X-Content-Type-Options`, `frame-ancestors`. The BFF now serves the interface, so these are its responsibility. Plus dependency scanning for the front-end build |
| **G17** | **No access recertification cycle** | Entra group membership drives entitlement, so a stale group is a stale entitlement. Define the review period and owner. IAM Recommender for the service-account grants |
| **G18** | **Org policy list is incomplete** | Add `compute.restrictVpcPeering` — which also protects the Firestore-not-Redis decision — plus `compute.restrictSharedVpcSubnetworks`, `compute.requireShieldedVm`, `essentialContacts` domain restriction, `storage.publicAccessPrevention` at org level, `compute.disableSerialPortAccess` |
| **G19** | **Log bucket retention is set but not locked** | Without a lock, anyone with logging admin can shorten retention and age out evidence. Do not lock in dev — see `05` — but decide it deliberately for production |
| **G20** | **No pre-go-live assurance gate** | CSOC will very likely require a penetration test or security assessment. Book it early: the lead time is usually weeks and the findings land on your critical path |
| **G21** | **Negative tests cover Apigee but not IAM or the BFF** | Add: a workload service account cannot call Vertex after the §18.4 removal; a non-CI principal cannot deploy a proxy; an unauthorised project cannot attach to the Apigee service endpoint; a forged session cookie is rejected; a state-changing request without a CSRF token is rejected |

---

## 5. Governance

| # | Gap |
|---|---|
| **G22** | **No RACI.** Platform team, usecase teams, the agent work, Colt network, CSOC, identity and the security reviewer all touch this. Who approves an Apigee proxy deploy? Who owns the Entra App Role definitions? Who signs off a new model in the allow-list? Who owns the certificate? |
| **G23** | **No change management path** for organisation policy changes, CSOC requests and IPAM allocations — each has an external dependency and a lead time |
| **G24** | **No prod promotion model.** Everything here is dev. Production needs its own Apigee organisation, its own address ranges and a promotion process. `aicoe-sharedwif` spanning both environments is the single shared component, and therefore the one to get right |
| **G25** | **No decision log.** Several decisions in this set are immutable or expensive to reverse — the Apigee networking model, the runtime encryption key, the analytics region, project identifiers. Record who decided, when, and on what evidence |

---

## 6. Closed since the first register

| Previously | Outcome |
|---|---|
| Cross-project serverless NEGs in the ingress project | **Corrected.** Backend services live with their Cloud Run service. Applied in `09` §20 |
| ILB timeout tuning for serverless backends | **Corrected.** Does not apply. The binding value is the Cloud Run request timeout |
| Does the sales agent need internet egress? | **Closed.** No. Default-deny egress stands, no Cloud NAT |
| RAG ingestion undesigned | **Closed.** Platform team owns it. Business unit comes from the verified Entra claim, never a request body field — `09` §15.6 |
| Indirect prompt injection | **Closed.** Application-side, four measures in `09` §17.6 |
| VPC-SC ingress rules for image push | **Moot.** VPC-SC deferred. Recorded as a re-entry condition |
| Apigee configuration backup | **Closed.** In Git, secrets excluded — `09` §22.13 |
| Terraform layering and apply order | **Closed.** `09` Part 25 |
| GDPR erasure path | **Accepted, not closed.** Holds while logging stays metadata-only. Revisit if prompt-content logging is switched on |
| MSAL fragility in the browser | **Closed by the BFF.** Refresh happens server-side |
| Browser-to-Apigee routing | **Closed by the BFF.** The browser never calls Apigee |
| IAP session versus long SSE streams | **Changed shape.** Now a BFF session concern — see G12 and spike S5 |
| Model Armor region availability | **Closed.** Available in europe-west1 |
| Apigee environment tier | **Closed.** Both LLM token policies are Extensible, so `llm` is Intermediate |

---

## 7. Priority

| When | Items |
|---|---|
| **Before Terraform** | G1, G2, G3 |
| **Before build** | G4, G5, G6, G9, G22 |
| **Before go-live** | G7, G8, G10, G11, G12, G13, G15, G16, G17, G18, G19, G20, G21 |
| **Alongside** | G14, G23, G24, G25 |

G5 deserves a note. Logout is the sort of thing that looks trivial and is not: with IAP and a BFF session and an Entra session all in play, "sign out" means three things, and getting two of them right is the same as getting none of them right on a shared machine.
