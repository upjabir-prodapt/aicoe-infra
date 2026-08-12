# 08 — LLM gateway design and best practices

**Revision R12.**

**Status:** current as of R3. Supersedes `superseded/llm-gateway-assessment.md`.

Two earlier concerns turn out to be solved by first-party features, and one new blocker appeared. Cost consequences of Pay-as-you-go are in `02` §1.1 and materially affect the Apigee-versus-Cloud-Run choice in §9.

---

## 1. Separate three things people conflate

Your instinct — a separate shared project that every usecase calls through Apigee — is right, but the "gateway" is three distinct pieces and they belong in different places.

| Piece | Where | Why |
|---|---|---|
| **Central inference project** `gclt-aicoe-dev-llm` under `shared/llm/` | new project, in the VPC-SC perimeter | Quota pool, billing boundary, CMEK ring, Model Armor templates and floor settings, semantic-cache index |
| **Policy enforcement** | **third environment `llm` in the existing `gclt-aicoe-dev-apigee` org** | A second Apigee org costs real money and buys no isolation you cannot get from a separate environment, envgroup and runtime service account |
| **Consumer entry point** | PSC endpoint `192.168.6.146` in `gclt-aicoe-dev-network`, private DNS `llm.aicoe-dev-int.colt.net` | Cloud Run cannot consume a service attachment directly. No CSOC request, no Colt routing |

One Apigee org, three environments: `int` (AI Hub API), `ext` (external/MCP), `llm` (inference). Three runtime service accounts, three envgroups.

---

## 2. Don't hand-roll token counting — it's native and GA now

This is the biggest change from my earlier assessment. <cite index="21-1">Apigee has two generally available policies for LLM workloads that give fine-grained control and rate limiting for AI traffic</cite>. <cite index="23-1">`LLMTokenQuota` enforces token consumption limits per API product over an interval, and `PromptTokenLimit` throttles based on prompt size — effectively a spike arrest for prompts</cite>.

The deployment pattern matters: <cite index="23-1">place an `EnforceOnly` instance in the request flow to reject calls once the quota is exhausted, and a `CountOnly` instance in the response flow to count tokens actually consumed</cite>. <cite index="21-1">Exceeding the quota returns HTTP 429</cite>.

Two consequences for your BU work:

**Attribution becomes a first-party feature.** <cite index="19-1">Apigee exposes a Tokens Consumption Report under Custom Reports, letting you drill into consumption by Developer App and Product</cite>. You get per-consumer token accounting without building a BigQuery pipeline for it — though you will still want the export for long-term cost analysis.

**Per-user counting is a documented pattern, and it confirms the identity requirement.** The `llm-token-limits-per-user` sample counts tokens per end user rather than per app, and it is explicit that <cite index="19-1">this needs both a client ID identifying the app and some form of user ID, likely from an ID token, and that this information has to reach Apigee for such control to work</cite>. That is exactly the condition I flagged — your backends must forward the the forwarded user context JWT on outbound LLM calls, or you can only attribute per service.

### The design decision this forces

`LLMTokenQuota` keys off **API Products**, which means Apigee must resolve a consumer — so a `VerifyAPIKey` or OAuth step is required in addition to the Google ID token that authenticates the calling service. You therefore acquire Apigee-managed credentials for internal services.

| Approach | Gets you | Costs you |
|---|---|---|
| **API Product per BU tier + OAuth2 client credentials per consumer service** (recommended) | Native token quota, product tiering, built-in consumption reports | One more credential per service in Secret Manager, with CMEK, a rotation owner and an expiry alert |
| Google ID token only, generic `Quota` keyed on a custom identifier | No new secrets | You lose product tiers and the built-in reports, and you hand-roll counting |

Take the first. The credential management is a known quantity and the reporting is the thing you actually want. Model API Products as BU tiers — a "Translation standard" product, a "Sales Agent standard" product — so quota changes are a product edit rather than a proxy redeploy.

---

## 3. Model Armor — use it in two layers, and check the region first

<cite index="12-1">Model Armor screens for prompt injection, jailbreak patterns, malicious URLs and sensitive data using Sensitive Data Protection infoTypes</cite>, and Apigee invokes it through the `SanitizeUserPrompt` and `SanitizeModelResponse` policies.

**Layer 1 — project floor settings, unbypassable.** <cite index="9-1">Model Armor integrates inline with Vertex AI's `generateContent` method for zero-code protection, either by passing a template ID or by configuring floor settings at the project level</cite>. Set floor settings on `gclt-aicoe-dev-llm`. This screens every call to that project **whether or not it came through the gateway** — which is the control that survives someone finding a way around Apigee. This alone is a strong argument for the central project.

**Layer 2 — Apigee policies, per consumer.** Per-BU templates attached in the proxy flow, so a BU handling customer data can have stricter settings than an internal one.

### The blocker

<cite index="9-1">Model Armor's supported regions are us-central1, us-east4, us-west1 and europe-west4</cite> — **not europe-west1**, where your entire platform runs. europe-west4 keeps you inside the EU, so residency is intact, but only if your `constraints/gcp.resourceLocations` policy is expressed as `in:eu-locations` rather than pinned to `europe-west1`. **If it is pinned, Model Armor cannot be used at all.** Check this before designing around it — it is a one-line policy question with a large design consequence.

### Two more cautions

The Apigee Model Armor policies are **Pre-GA**: <cite index="11-1">they fall under the Pre-GA Offerings Terms, are provided as-is and may have limited support</cite>. And <cite index="14-1">`SanitizeUserPrompt` is an Extensible policy, whose use may carry cost or utilisation implications depending on your Apigee licence</cite>. Confirm your entitlement covers Extensible policies before this lands in an LLD as a committed control. The GA token policies are safe to commit to; the Model Armor policies are not, yet — but the project-level floor settings are not Apigee-dependent, so Layer 1 is committable regardless.

---

## 4. Streaming is solved — I was wrong to flag it as an open risk

The samples repo has `llm-sse-security` (a proxy that streams server-sent events with Model Armor inspecting the response) and `llm-sse-logging` (SSE with response logging to Cloud Logging). Both are first-party, notebook-driven samples. Start from `llm-sse-security` for the sales agent's `/research/{id}/stream` endpoint rather than treating SSE-through-Apigee as unproven.

Payload size remains a genuine constraint, so the `gs://` URI rule for multimodal document translation still stands.

---

## 5. Semantic caching — real savings, one sharp security edge

The repo has `llm-semantic-cache` and `llm-semantic-cache-v2`, the latter using out-of-the-box policies. Both combine Apigee's cache layer with Vector Search as the embeddings store — and you already run Vector Search, so the building block exists.

**The edge: a shared semantic cache across business units is a cross-tenant data leak.** Semantic cache matches on meaning, not exact string, so a Finance prompt can return a cached response generated from a Legal prompt. The cache key **must** include the business unit, and the cache entries must be CMEK-encrypted with a defined retention. Treat the cache as a data store holding prompt and response content, subject to the same DLP and retention rules as BigQuery — not as an infrastructure detail. This is not something the samples will warn you about, because they are not multi-tenant.

---

## 6. Check the MCP direction before you build `mcp-server`

The repo has an `apigee-mcp` sample featuring an MCP server that discovers API specs from Apigee API hub, dynamically generates tools for LLMs, and exposes them through Apigee — plus ADK agent samples that use API hub to provide APIs as tools. Given that Bill Lewis builds ADK agents and your roadmap has an `mcp-server` Cloud Run service, it is worth an hour to check whether Apigee's MCP capability replaces part of what you were going to build. If it does, `mcp-server` may become a thin shim or disappear.

---

## 7. Sample-to-requirement mapping

| Your requirement | Sample to start from |
|---|---|
| Per-BU token quota and cost attribution | `llm-token-limits`, then `llm-token-limits-per-user` for the identity-forwarding pattern |
| Prompt and response safety | `llm-security-v2` (out-of-the-box Model Armor policies) |
| SSE streaming for the research agent | `llm-sse-security`, `llm-sse-logging` |
| Cost reduction on repetitive translation | `llm-semantic-cache-v2` |
| Multi-model or multi-region failover | `llm-circuit-breaking`, `llm-routing` |
| Prompt/response audit trail | `llm-logging` |
| Agents as consumers | `adk-*` samples, `apigee-mcp` |
| Proxy CI/CD | `deploy-apigee-proxy` (Maven plugin + Cloud Build) — adapt to GitLab, since proxy bundles have no Binary Authorization equivalent |

---

## 8. Anti-patterns to avoid

1. **A second Apigee org for the LLM gateway.** Cost with no isolation benefit over a separate environment and service account.
2. **Making the gateway the only path with no break-glass.** Document a named service account that can call Vertex directly, IAM-gated, alerted on every use.
3. **Logging full prompts by default.** Log token metadata always, prompt content only redacted or not at all. This is a GDPR purpose-limitation decision, and you are creating one place that sees every prompt across every BU.
4. **One semantic cache shared across BUs.** See §5.
5. **Relying only on Apigee policy for safety.** Project floor settings are the unbypassable layer; Apigee policies are the per-consumer refinement.
6. **Inline multimodal payloads.** `gs://` URIs in `fileData`, always.
7. **Ignoring 429 handling in agents.** An agent that hits a token quota mid-run leaves partial state. The sales agent's async job needs explicit 429 handling with retry-after, or a quota exhaustion becomes a stuck research job.
8. **Committing Pre-GA policies as controls in a signed-off LLD.** Split the design into what is GA (token policies, floor settings) and what is Pre-GA (Apigee Model Armor policies).

---

## 9. Revised decision order

1. **Is `gcp.resourceLocations` `in:eu-locations` or pinned to `europe-west1`?** Determines whether Model Armor is available at all.
2. **Does your Apigee licence include Extensible policies?** Determines whether Layer 2 is available.
3. **Call volume against Apigee per-call pricing.** Still the commercial gate.
4. **API Products per BU tier, with OAuth2 credentials per consumer service** — accept it, and plan the secret rotation.
5. **What gets logged**, signed off by data protection rather than engineering.
6. Then build, starting from `llm-token-limits` and `llm-sse-security`.
