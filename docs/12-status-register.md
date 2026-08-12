# 12 — Status register

**Revision R12.** One view of everything: what is settled, what was corrected, what is designed but unproven, and what is still open.

Four states, and the distinction between the middle two matters. A design document saying "do X" is not the same as X being verified.

| State | Meaning |
|---|---|
| **Settled** | Decided, written into the current documents, nothing further needed |
| **Corrected** | Was wrong in an earlier revision, now fixed. Listed so nobody works from an old copy |
| **Specified, unverified** | The design says how, but it rests on an assumption nobody has tested |
| **Open** | No answer yet |

---

## 1. Settled — 21 decisions

| # | Decision | Where |
|---|---|---|
| 1 | Apigee non-peered, Private Service Connect throughout. Immutable after org creation | `11` §1 |
| 2 | Backend-for-Frontend rather than tokens in the browser | `11` §1 |
| 3 | Apigee sits in the user request path, because per-user rate limiting has nowhere else to live | `11` §1 |
| 4 | Entra App Roles for entitlement, Security Groups for administration | `11` §4 |
| 5 | Quota keyed on `oid`. Department is a reporting dimension, never a quota key | `11` §6.1 |
| 6 | **One IAP**, at the front door, authenticating people. The backend hop uses **Cloud Run IAM** with `run.invoker` scoped to the Apigee service account | `11` §7.2 |
| 7 | `int` environment Base, `llm` environment Intermediate | `09` §14.5 |
| 8 | Firestore for sessions, not Redis — Memorystore basic tier would peer the host VPC | `11` §5.3 |
| 9 | VPC Service Controls deferred, with compensating controls and an accepted residual risk | `11`, `09` |
| 10 | Two address ranges split by Colt reachability. One CSOC-opened address | `09` §0.4 |
| 11 | One 400-day user-defined log bucket, three folder sinks, `_Default` left short to avoid double billing | `05` |
| 12 | Apigee configuration in Git; credentials and key material in Secret Manager | `09` §22.13 |
| 13 | Terraform layering static / network / infra, with the cross-project apply order | `09` Part 25 |
| 14 | Business unit at RAG ingestion comes from the verified Entra claim, never a request body field | `09` §15.6 |
| 15 | Indirect prompt injection handled application-side, four measures | `09` §17.6 |
| 16 | GDPR erasure path accepted rather than solved, on the basis that logging stays metadata-only | `11` §11 |
| 17 | Logout clears the application session, refresh token and IAP session by default. Entra sign-out is a separate "sign out everywhere" action | `13` §1 |
| 18 | Session identifier rotates on authentication and on privilege change, with a 30-second grace window for in-flight requests | `13` §2 |
| 19 | Refresh is proactive at 80% of lifetime with jitter, serialised by a 10-second Firestore lease | `13` §3 |
| 20 | Fail closed on session-store failure — 503, never a fallback. Instance-level cache of 5 to 15 seconds, bypassed on logout | `13` §4 |
| 21 | Platform limits inventoried, with two that constrain the design: Firestore's one-write-per-second per document, and Model Armor's 1,200 queries per minute | `13` §6 |

---

## 2. Corrected — 12 things that were wrong

These were all in earlier revisions of this document set. If someone is holding a printed copy from before R10, these are the things that copy gets wrong.

| # | Was | Is | Found by |
|---|---|---|---|
| 1 | Cross-project serverless NEGs in the ingress project | Backend services and NEGs live in the same project as the Cloud Run service | Documentation |
| 2 | Load balancer timeout tunable for serverless backends | Does not apply. Cloud Run request timeout is the binding value | Documentation |
| 3 | Model Armor unavailable in europe-west1 | **Available.** Only the built-in Vertex integration wants another region | Your challenge |
| 4 | Filters screen 2,000 tokens | 10,000 per filter, 130,000 for sensitive data, 4 MB input ceiling | Your challenge |
| 5 | Cloud Run budget 49 instances | **127.** Two addresses per instance at steady state, four times peak during rollout, against 508 usable in the `/23` workload subnet. Recorded as 31 while the subnet was a `/25` | Documentation |
| 6 | Rate limits return 429 | **500 by default** for `Quota` and `SpikeArrest`. `LLMTokenQuota` does return 429 | Documentation |
| 7 | SpikeArrest is always per message processor | Only when `UseEffectiveCount` is false, and the default template sets it true | Documentation |
| 8 | `192.168.0.0/22` as the second range | Invalid CIDR. Superseded anyway — the unrouted range is now `192.168.4.0/22` | Address arithmetic |
| 9 | Apigee reached via a generic PSC endpoint | The documented **service endpoint** routing option, chosen at provisioning | Documentation |
| 10 | Firewall rules needed for health checks and the proxy subnet | Not needed. Serverless and PSC NEG backends are not in the VPC | Documentation |
| 11 | `X-Serverless-Authorization` never sent by a caller | True **when IAP is in the path**. With no IAP it is the documented header for a Cloud Run IAM token. The rule was stated too broadly. The BFF must still strip inbound ones, because the BFF is behind IAP | Your challenge, twice |
| 12 | Both LLM token policies assumed possibly Standard | Both **Extensible**, so `llm` must be Intermediate | Documentation |
| 13 | Session tokens "envelope-encrypted with a Cloud KMS key", implying a KMS call per read | Cached data encryption key wrapped by KMS. A KMS round trip per request would add 10-30 ms to every call and consume quota at full request rate | Limits review |

Three of these came from you pushing back rather than from my own checking. That is worth noting for how the remaining unverified items should be treated.

---

## 3. Specified but unverified — 9 items

The design says how. Nobody has proven it.

| # | Item | If it fails | Spike |
|---|---|---|---|
| **V1** | Cloud Run IAM through a load balancer via `X-Serverless-Authorization`, **and** IAP on an internal load balancer backend service | Arm 1 decides the backend path, arm 3 decides the front door. Fallback for the backend is IAP with a dedicated OAuth client | S1, three arms |
| V2 | Cloud Armor attaches to a regional internal Application Load Balancer | No WAF claim in the design. Compensating control is that only ZPA reaches `.20` | S6 |
| V3 | Silent token acquisition produces no visible prompt in Colt's browser build | Single-login degrades to a visible redirect on first API call | S3 |
| V4 | Cloud Tasks can dispatch to a Cloud Run service with `ingress=internal` | Worker needs `internal-and-cloud-load-balancing` | S10 |
| V5 | Server-sent events survive Apigee with Model Armor attached | Research agent user experience changes materially | S8 |
| V6 | The `gs://` URI path works and the inline payload ceiling is known | Document translation through the gateway breaks at some size | S9 |
| V7 | Vector Search `restricts` cannot be bypassed, and ingestion ignores a body-supplied business unit | Tenant isolation has a hole on the write side | S11 |
| V8 | `EXECUTION_SKIPPED` is handled rather than silently passing | Oversized prompts go unscreened without anyone noticing | S13 |

**V1 is the only one that changes the architecture**, and it is larger than it looks — it underpins the front door as well as the backend path, and it has been assumed since the first revision without test. The rest change a parameter, a component setting or a user experience.

**A note on how V1 got here.** The backend authentication mechanism moved four times — IAP on the load balancer, IAP on the Cloud Run service, back to the load balancer, and finally to Cloud Run IAM with no IAP at all. Each move was made on documentation reading rather than testing. The final position is the simplest and was in the design you were shown early on; earlier revisions wrongly asserted it could not work, by applying a rule about browser traffic to a machine caller. Spike S1 settles it.

---

## 4. Open — 23 items

### Must resolve before Terraform

| # | Item |
|---|---|
| O1 | CSRF protection design for the BFF — a design decision, not a test |
| O2 | Certificate ownership and DNS-01 automation. Needs the public DNS zone team, so it has a lead time |
| O3 | Apigee cost modelling — Extensible per-call rate against expected AI volume |
| O4 | Confirm `192.168.4.0/22` against Colt corporate use |
| O5 | Per-service `maxScale` allocation within the 127-instance ceiling |

### Must resolve before build

| # | Item |
|---|---|
| O11 | RACI — who approves proxy deploys, owns App Roles, owns the certificate |

### Must resolve before go-live

| # | Item |
|---|---|
| O12 | Prompt-logging and per-user-metrics purpose and retention — data protection sign-off |
| O13 | Model output sanitisation on render |
| O14 | Agent tool-call authorisation in the user's context |
| O15 | New-usecase onboarding runbook |
| O16 | Chargeback process and budget alerts |
| O17 | End-to-end latency budget, measured |
| O18 | Firestore backup, restore and a tested failure mode |
| O19 | Container hardening standard |
| O20 | Security headers and Content Security Policy on the BFF |
| O21 | Access recertification cycle for Entra groups |
| O22 | Additional organisation policies, including `compute.restrictVpcPeering` |
| O23 | Log bucket retention lock decision for production |
| O24 | Penetration test or security assessment — book early, findings land on the critical path |
| O25 | Negative tests for IAM and the BFF, not just Apigee |
| O26 | Performance and load test under combined concurrency |

### Alongside

| # | Item |
|---|---|
| O27 | Change management path for org policy, CSOC and IPAM requests |
| O28 | Production promotion model, and a decision log for the immutable choices |

---

## 5. What this means in practice

**You can start building now.** Runbook Parts 1 to 17 — organisation policies, APIs, service agents, KMS, logging, network, Shared VPC, PSC to Google APIs, Artifact Registry, Binary Authorization, Secret Manager, both identity federations, Apigee provisioning, Vector Search, data services, Firestore and the LLM project — depend on **none** of the open or unverified items.

**Parts 19 to 22 wait on V1 and O1.** The Cloud Run settings, load balancers, PSC wiring and Apigee proxies all depend on whether Shape A holds, and the BFF cannot be written without a CSRF decision.

**Three things have an external lead time** and should be started this week regardless of build order: the certificate and DNS-01 automation (O2), the penetration test booking (O24), and the IPAM confirmation (O4).

**One step is easy to defer and should not be.** Runbook §18.4 removes `roles/aiplatform.user` from every workload service account. Until it is done, every control in the AI gateway is advisory. It is not on any open list because it is already specified — it just has to actually happen.
