# 10 — Validation log

**Revision R12.**

Every load-bearing claim in the design set, checked against Google's own documentation. Verdicts are one of **confirmed**, **corrected** or **open**. Corrections have been applied to `09-implementation-runbook-console.md` (now revision R6) and are listed with the section that changed.

---

## Round 1 — networking

### V1. Can Cloud Run reach Apigee without a load balancer?

**Claimed:** create a generic Private Service Connect endpoint pointing at the Apigee instance's service attachment, and call it from Cloud Run.

**Verdict: confirmed, with a correction to how it is created.**

Google documents an internal-routing option for Apigee provisioned with Private Service Connect, called the **service endpoint** option. Its own instructions for calling an internal proxy are: retrieve the service endpoint IP, then `curl -H "Host: ENV_GROUP_HOSTNAME" https://ENDPOINT_IP/basepath`. That is exactly the shape the design needs.

The correction is that this is a **provisioning-time routing choice**, not a generic endpoint you build yourself afterwards. It belongs in Part 14 alongside the other immutable-ish decisions, not in Part 21 as an afterthought.

Second correction: Google's example uses `-k` to disable certificate verification, because the certificate is issued for the hostname and not the IP. Building that into a service would teach it to accept any certificate. The private DNS record in §6.9 exists precisely so callers use the hostname and verification stays on.

**Applied:** §14.3 step 6 (new), §21.3 (rewritten).

### V2. Is a PSC network endpoint group the right shape for internal access?

**Verdict: no — and this retrospectively supports the option G decision.**

The northbound Private Service Connect documentation describes attaching a PSC network endpoint group to an **external** Application Load Balancer, and notes that the classic global external load balancer does not support PSC NEG backends at all. The pattern exists for exposing Apigee to the internet.

Option B would have put a PSC NEG on an *internal* Application Load Balancer. That is not the documented arrangement, so option B carried a networking risk on top of the authentication risk that killed it. Choosing option G avoided both.

**Applied:** §21.3 closing note.

### V3. Consumer accept list behaviour

**Verdict: confirmed, with two operational details worth knowing.**

The limit on PSC NEG connections per project to an Apigee instance is 100. More importantly, **removing a project from the accept list does not sever existing connections** — they keep working, and only new ones are refused. Revoking access means deleting the existing connections, or recreating the instance.

So the accept list is admission control, not a revocation mechanism. If a project must lose access urgently, the accept list alone will not do it.

**Applied:** §21.4.

---

## Round 2 — rate limiting

### V4. Is SpikeArrest per message processor?

**Verdict: corrected — true only when one element is absent.**

The documentation is explicit that spike-arrest counts are not synchronised across message processors unless `UseEffectiveCount` is enabled, and that with several processors you multiply the configured rate by the processor count to get the real arrest rate.

But **the default policy template ships with `UseEffectiveCount` set to `true`**. So the "N times your configured rate" warning applies only if someone removes it or writes the policy from scratch. The fix is one element, not an architectural workaround.

Earlier revisions of this design treated the multiplier as unavoidable and told you to measure it and publish the measured figure. That was over-cautious.

**Applied:** §22.11 (rewritten). Spike **S6.1** in `03` is downgraded from a measurement exercise to a configuration check.

### V5. What status code does a rate limit return?

**Verdict: corrected — and this one would have failed your tests.**

For `Quota` and `SpikeArrest` the documented default is a generic **500 Internal Server Error**, not 429. It can be changed to 429 via an organisation-level property (`features.isHTTPStatusTooManyRequestEnabled`), which on some plans needs a support request.

This matters operationally, not just cosmetically. A 500 tells a client the server broke, so a well-behaved caller retries immediately — the worst possible response to a rate limit. The async translation worker and any agent will behave badly against a default configuration.

Note the asymmetry: `LLMTokenQuota` **does** return 429. So the AI token limits and the classic request limits behave differently out of the box, and you cannot infer one from the other.

**Recommended fix:** a FaultRule in the proxy that catches quota and spike-arrest faults and returns 429 with `Retry-After`. That is under your control and does not depend on a support ticket.

**Applied:** §22.11, §22.9 test list, §24 test 11b.

### V6. Quota counter scope

**Verdict: new constraint, not previously documented in this set.**

Quotas apply to **individual API proxies and are not distributed among them**. Three proxies in one API product do not share a counter, even with identical policy configuration.

Invisible today because the AI gateway is a single proxy. If it is ever split — for example a separate proxy for streaming — the token budget silently multiplies by the number of proxies.

**Applied:** §22.12 (new).

### V7. Sub-minute quota intervals

**Verdict: new constraint.** The `second` time unit is only supported for non-distributed counters, and Google's own guidance is to use `SpikeArrest` for sub-minute limiting rather than a per-second `Quota`.

**Applied:** §22.12.

### V8. Policy ordering

**Verdict: confirmed.** Spike arrest first because it needs no credential and can therefore shed load before authentication costs anything, then credential verification, then quota enforcement keyed on the verified identity. The design's §22.8 ordering already matched this.

### V9. The four-policy model

**Verdict: confirmed, with sharper language available.**

The documentation distinguishes the four policies explicitly and states they are not substitutes: `SpikeArrest` protects the backend from spikes; `Quota` limits calls per consumer over longer intervals where accurate counting matters; `LLMTokenQuota` manages total token consumption per API product for cost control; `PromptTokenLimit` throttles on prompt size to protect against token abuse and denial of service, described as the spike-arrest equivalent for tokens.

One detail worth carrying: `PromptTokenLimit` enforces a rate but does **not** maintain a persistent long-term count, so it cannot stand in for `LLMTokenQuota` for billing or budget purposes. The layered design in §22.8 is correct, and now has a documented rationale rather than an inferred one.

**Applied:** §22.8 explanatory paragraph.

---

## Round 3 — Cloud Run addressing

### V10. How many addresses does a Cloud Run instance consume?

**Verdict: corrected, and this is the most consequential finding.**

The design assumed one address per instance with a 2.5x allowance for revision churn, producing a budget of 49 total instances. Google's documentation is stricter on both counts:

| Documented behaviour | Consequence |
|---|---|
| Multiply the instance-count metric by **2** to estimate addresses in use | Steady state is ~2 addresses per instance, not 1 |
| Worked example: revision 1 scaling 100→0 while revision 2 scales 0→100 requires **400** addresses, `(100+100) x 2` | A rollout needs **4x** peak, not 2.5x |
| Addresses are retained for up to **20 minutes** after a revision scales down | This is the mechanism that creates the overlap |
| Addresses are reserved in **blocks of 16** | Effective capacity is slightly below the raw count |
| Subnet must be `/26` or larger | `192.168.4.0/23` satisfies this |

**Corrected budget: usable addresses ÷ 4 = the ceiling**, down from the 49 the design assumed. On the `/25` this stage was written against that gave 31; on the `192.168.4.0/23` workload subnet now in the design it gives **508 ÷ 4 = 127**. The arithmetic is what was validated here, not the figure.

For a development platform that is comfortable — 127 concurrent instances is a lot of parallel work — but it is a hard ceiling and the failure mode is an unhelpful error during a rollout rather than a clear "out of addresses" message.

**Applied:** §19.3 (rewritten with the derivation, a revised split, and a monitoring threshold of 60 addresses in use).

### V11. One subnet or several for Cloud Run?

**Verdict: confirmed — one.** Google recommends placing multiple resources on the same subnet for allocation efficiency and ease of management. So if more headroom is needed the answer is a larger single subnet, which means another IPAM request, since `192.168.4.0/22` is fully carved.

**Applied:** §19.3 closing note.

---

## Round 4 — IAP and Cloud Run authentication

### V12. Is `X-Serverless-Authorization` something Apigee should send?

**Verdict: no — confirmed. It is IAP's internal hop.**

Google states plainly that IAP authenticates to Cloud Run using the `X-Serverless-Authorization` header, and that Cloud Run passes the header to your service after stripping its signature. It is generated by IAP, not by an external caller. A client that tries to emulate it is imitating an internal mechanism.

The two mechanisms are distinct and not interchangeable:

| Mechanism | Caller sends | Validated by |
|---|---|---|
| Cloud Run IAM | Google ID token whose audience is the service URL | Cloud Run, against `roles/run.invoker` |
| IAP | IAP ID token whose audience is the **OAuth client ID**, in `Authorization` — or `Proxy-Authorization` if the application already uses `Authorization` | IAP, before the request reaches the service |

The design was already correct in substance — it specifies a Google ID token with the IAP client id as audience, which is the IAP mechanism — but the distinction was never stated, and it is exactly the trap that other versions of this architecture fell into.

**Applied:** `11` §7, runbook §20.7.

### V13. A new requirement for the BFF

**Verdict: found while verifying V12. Not previously in the design.**

Google's documentation carries an explicit warning: because Cloud Run passes `X-Serverless-Authorization` through to your service, **a service that forwards requests onward to another Cloud Run service requiring IAM authentication must remove that header first.**

The BFF does exactly that — it sits behind IAP, receives the header, and forwards to Apigee and onward to the backends. **The BFF must strip `X-Serverless-Authorization` before making any outbound call.** Left in place it is at best confusing and at worst causes the downstream hop to reject the request.

**Applied:** runbook §19.4.

### V14. Where should IAP be enabled — load balancer or Cloud Run?

**Verdict: the design chose the option Google does not recommend.**

Google documents two ways to enable IAP for Cloud Run and recommends **directly on the Cloud Run service**, because it protects the `run.app` endpoint without provisioning load balancer resources, is simpler, and avoids load balancer cost. Enabling on a backend service is presented as the option for multi-region services behind one global backend service needing central access management.

Two hard constraints come with it:

- **IAP cannot be used on both the Cloud Run service and the load balancer.** It is one or the other. If enabled on the load balancer, IAP secures only traffic through the load balancer — the `run.app` URL remains unprotected unless the default URL is disabled or ingress is restricted.
- **IAP increases latency**, and Google advises against it for latency-sensitive services.

Also worth recording: IAP now uses a **Google-managed OAuth client by default**, with a custom client needed only for access from outside the organisation. That removes much of the concern about creating a second OAuth brand in the ingress project, though programmatic access still needs a client id to use as the token audience.

**Consequence:** this reopens the shape of the southbound path — see `11` §7. Applied there.

### V15. Are `LLMTokenQuota` and `PromptTokenLimit` Standard or Extensible?

**Verdict: both Extensible. Confirmed, and it settles the environment tier.**

Google's policy reference states for each of them that it "is an Extensible policy and use of this policy might have cost or utilization implications, depending on your Apigee license", and separately that **extensible policies can be used with intermediate and comprehensive environment types only**.

So the `llm` environment must be **Intermediate** — not a judgement call. The Model Armor policies are Extensible too, so the AI gateway was heading there regardless; the token policies remove the last doubt.

The `int` environment stays **Base**: every policy in the user API proxy is Standard, and standard policies work with any environment type. Worth protecting deliberately, because one extensible policy reclassifies the whole proxy to roughly five times the per-call rate. Google's own guidance is that where a standard and an extensible policy would both work, use the standard one.

**Applied:** runbook §14.5.

## Still open

| # | Claim | Why it is still open |
|---|---|---|
| O1 | IAP invokes Cloud Run as its own service agent, which must hold `run.invoker` | Not yet verified against documentation. Option G depends on it entirely — this is the next thing to check |
| O2 | Model Armor's built-in Vertex AI integration requires a template in a region the location policy forbids | Sourced from a Google engineer's article, not the reference documentation |
| O3 | Whether `LLMTokenQuota` and `PromptTokenLimit` are Standard or Extensible policies | Determines whether the `llm` environment can run on Base. Cost question |
| O4 | Cloud Armor attachment to a regional internal Application Load Balancer | Asserted in the design, never verified |
| O5 | Cloud Tasks dispatch to a Cloud Run service with `ingress=internal` | Spike S11 |
| O6 | Whether the console exposes the Apigee service endpoint, or whether it needs Cloud Shell | Minor, affects §21.3 wording only |

O1 is the one to do next: it is load-bearing for the whole user path, and if it turns out that a serverless NEG behind IAP behaves differently from the assumption, Part 20 changes.

---

## Round 4 — where the Private Service Connect addresses actually come from

Prompted by a direct question: how were `192.168.6.146` and `192.168.6.147` finalised? The honest answer is that the **placement rule** was derived and the **specific values were assigned by me**. Verification shows that assigning them was the wrong approach for both.

### V12. The Apigee service endpoint address

**Claimed:** `192.168.6.146`, a static internal address in `gclt-aicoe-dev-internal-ew1`.

**Verdict: corrected — the address is not yours to choose.**

Google's instructions for the service endpoint routing option say to *get* the IP of the service endpoint, and point at a "List endpoints" procedure to look it up. It is allocated as part of Apigee's internal Private Service Connect routing configuration, selected at provisioning. R6 already noted this in §21.3, but §0.6 and the firewall rule still printed `192.168.6.146` as a decision, which was inconsistent.

**Applied:** §0.6 rewritten as an allocation table with an owner per address, plus a fill-in table to record actual values. §6.7 gains an instruction to revisit the egress rule once the real addresses exist.

### V13. The Vector Search address, and a repeating-cost mistake

**Claimed:** `192.168.6.147`, created manually as a Private Service Connect endpoint.

**Verdict: corrected, and the correction removes recurring manual work.**

Two findings. First, the service attachment is exposed **per deployed index** — it is read from `deployedIndexes.privateEndpoints.serviceAttachment`, not from the index endpoint. Second, Google documents two connection modes: automatic, using a **service connection policy** that allocates the address and creates the forwarding rule for you; and manual, which the documentation frames as the choice only when you need several addresses for one service attachment — described as uncommon.

The design specified manual mode by implication. Combined with "per deployed index", that means **every future index deployment would need a hand-made address, a hand-made forwarding rule and a firewall-rule edit.** A recurring manual task that is certain to be forgotten once, at which point the Sales Agent stops working for reasons nobody connects to an index redeployment.

**Applied:** §15.4 rewritten around a service connection policy, with the manual procedure kept as a documented fallback. §15.5 gains the reasoning.

### V14. Two requirements the design had right, now with a source

**Confirmed:** the consumer endpoint address must be an internal IPv4 address from a **regular subnet in the same region** as the producer's service attachment. `gclt-aicoe-dev-internal-ew1` in `europe-west1` satisfies this.

**Confirmed and now explicitly required:** where a VPC has egress deny rules, you must create a specific egress allow rule permitting traffic to the endpoint's internal address. The design's §6.7 rule 2 exists for this. The correction is that its destinations were placeholders, so the rule needs revisiting after provisioning — the most likely cause of an otherwise baffling "cannot reach the gateway" fault.

### V15. A permission the design was missing

**New.** Creating a Private Service Connect endpoint in a **service project** against a subnet in the **host project** needs additional roles granted on the host project, not just the service project. Parts 8, 15 and 21 all do this, and Part 0.1 listed no host-project roles beyond Shared VPC Admin.

**Applied:** Part 0.1 roles table.

### What this round changes about the IP plan generally

The plan was written as though every address were an allocation decision. In fact only three are: the AI Hub load balancer VIP, the Google APIs global address, and the subnet ranges themselves. Everything else is either allocated by a service or ephemeral.

The revised §0.6 reflects that, and carries a fill-in table so the actual values are recorded in one place as they are discovered — rather than being embedded as assumptions in a DNS record, a firewall rule and a target server, which is how three copies of a wrong address end up in production.
