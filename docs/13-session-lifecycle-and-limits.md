# 13 — Session lifecycle and platform limits

**Revision R12.** Design for the five open items O6 to O10. Everything here is a decision, not an option — the alternatives considered are noted where the choice was close.

One finding in §5 changes the session design in `11` §5.2, and is called out there.

---

## 1. O6 — Logout across three sessions

### The problem, stated precisely

Signing in creates **three** sessions and one stored credential:

| Session | Held where | Created by |
|---|---|---|
| Application session | Firestore document + `__Host-AISESSION` cookie | the BFF |
| IAP session | Google cookie on your domain | IAP, after workforce federation |
| Entra session | Microsoft cookie at `login.microsoftonline.com` | Entra, during the IAP redirect |
| Refresh token | Firestore, envelope-encrypted | the BFF's code exchange |

**The failure mode that matters.** Clear only the application session, and the next person at that browser reaches the BFF, has no application session, so the BFF starts the authorisation code flow — but the IAP session is still valid and the Entra session is still valid, so both complete silently. They are now signed in as the previous user, having clicked nothing.

On a shared machine that is a serious problem. Clearing the IAP session is therefore **mandatory**, not a nicety.

### The design

`POST /auth/logout` — a POST, and CSRF-protected. A logout reachable by GET is itself a cross-site request forgery vector, because an attacker can sign a user out with an image tag.

Order matters:

1. **Revoke the refresh token at Entra** first, while you still have it. Best effort — log a failure, do not abort the logout.
2. **Delete the Firestore session document.** Delete it, do not mark it expired. A marked document is a document somebody's code will eventually read.
3. **Clear the cookie** with `Max-Age=0` and *identical* attributes, including the `__Host-` prefix and `Path=/`. A cookie cleared with mismatched attributes is not cleared.
4. **Redirect to IAP's clear-cookie endpoint** to end the IAP session.
5. **Optionally** redirect onward to Entra's RP-initiated logout.

### Step 5 is a policy decision, not a technical one

Signing out of Entra signs the user out of **every** Microsoft application in that browser — Outlook, Teams, SharePoint. On a shared clinical or kiosk machine that is exactly right. On someone's own laptop it is hostile, and they will stop using the logout button, which is worse than not having one.

**Recommended:** two options in the interface.

| Action | Clears |
|---|---|
| **Sign out** (default) | Application session, refresh token, IAP session |
| **Sign out everywhere** | The above plus the Entra session |

Default to the first. Make the second obvious on any device flagged as shared.

### Also required

- **Logout must be idempotent.** Called twice, or with a session already gone, it returns success and still clears cookies.
- **Expiry must run the same path.** Idle timeout and absolute expiry delete the document and clear the cookie — not just refuse the request.
- **Log every logout** with the reason: user-initiated, idle, absolute, or revoked. You will want this the first time somebody reports being signed out unexpectedly.

---

## 2. O7 — Session identifier rotation

### When to rotate

| Trigger | Why |
|---|---|
| **On successful authentication** | Session fixation defence. A pre-authentication identifier must never become the post-authentication one |
| **On privilege change** | If a token refresh returns a different `roles` array, the session's authority has changed and the identifier should too |
| Not on every refresh | Access-token renewal is not a privilege change. Rotating there is churn with no benefit |

### The mechanism, and the part that bites

1. Generate a new 256-bit random identifier.
2. Write a **new** Firestore document keyed on its hash, carrying the session state forward.
3. Set the new cookie.
4. Retire the old document.

Step 4 is where naive implementations break. Delete the old document immediately and any **in-flight concurrent request** still carrying the old cookie fails — and a browser routinely has several requests in flight.

**Use a grace window.** Mark the old document `superseded_by: <new hash>` with a 30-second expiry, and accept it read-only during that window while returning the new cookie again. After 30 seconds it is deleted. Long enough for in-flight requests, short enough that a stolen old identifier is worthless.

### Two rules that are easy to get wrong

- **The identifier is accepted from the cookie and nowhere else.** Not a URL parameter, not a header, not a request body. Anything else is a session-fixation vector and puts the identifier in logs and referer headers.
- **Log rotation events** with the trigger. A rotation you cannot explain is an incident.

---

## 3. O8 — Refresh stampede

### The problem

The access token expires. Several concurrent requests notice at the same moment and each calls Entra's token endpoint with the same refresh token. Under refresh-token rotation, the first call succeeds and **invalidates that refresh token**. Every other call receives `invalid_grant`, and the naive response to `invalid_grant` is to sign the user out.

The user experiences a random sign-out under load. It is intermittent, load-dependent and miserable to reproduce.

### The design — two mechanisms together

**Refresh proactively, with jitter.** Renew at 80% of the access token's lifetime rather than on expiry, and add random jitter of a few per cent. Proactive renewal means most requests never encounter an expired token; jitter stops multiple Cloud Run instances synchronising onto the same instant.

That reduces the frequency. It does not eliminate the race, so:

**Lease the refresh in a Firestore transaction.**

1. A request finding the token due for renewal opens a transaction on the session document.
2. It sets `refresh_lease_until = now + 10s` if no live lease exists. One request wins.
3. The winner calls Entra, writes the new tokens, clears the lease.
4. Losers back off — 50 ms, 100 ms, 200 ms, up to about 2 seconds — re-reading the document each time, and proceed as soon as new tokens appear.
5. If the lease expires with no new token, the winner died. The next request takes the lease and retries.

### Three details that decide whether this actually works

- **The Entra call must time out well inside the lease.** A 10-second lease with a 30-second HTTP timeout means the lease expires while the call is still running, a second request starts another refresh, and you have recreated the stampede.
- **`invalid_grant` must not loop.** Terminate the session, clear cookies, force re-authentication. Do not retry — the refresh token is gone and retrying only produces more failures.
- **Cap the wait.** A loser that waits more than about two seconds should fail the request with a 503 rather than hold a Cloud Run instance open. Holding instances during a refresh problem is how a token issue becomes a capacity outage.

---

## 4. O9 — Session read latency and Firestore failure

### Latency

Every API call reads the session. That read is now on the critical path of every request.

| Control | Effect |
|---|---|
| **Keep the session document small** | Firestore returns whole documents. Store identifiers, timestamps and wrapped tokens — never anything large |
| **Cache in the instance, briefly** | A 5 to 15 second in-memory cache keyed on the session hash removes most reads for a chatty client |
| **Bypass the cache** on logout, rotation and any privilege-sensitive operation | Otherwise a revoked session stays alive for the cache lifetime |
| **Target and alert** | p95 session read under 25 ms. Alert above it — this is the number that will quietly degrade |

The cache trade is explicit: a revoked session remains valid for up to the cache lifetime. Fifteen seconds is a reasonable exposure for an internal platform; on a shared machine combine it with the logout path in §1, which bypasses the cache.

### When Firestore is unavailable

**Fail closed. Always.** There is no degraded mode — you cannot validate a session without the store, and any fallback that lets a request through unauthenticated is worse than an outage.

| Condition | Response |
|---|---|
| Firestore unreachable or erroring | **503** with `Retry-After`. Never 200, never a fallback path |
| Session document not found | **401**. Distinct from the above — do not collapse them, or you cannot tell an outage from normal expiry in the logs |
| Firestore call | 2 second timeout, comfortably inside the Cloud Run request timeout |
| Sustained error rate | Circuit-break to a fast 503 rather than waiting on timeouts. Waiting exhausts Cloud Run instances and turns a dependency problem into a capacity outage |

Alert on the Firestore error rate. This is a hard request-path dependency and it did not exist before the BFF.

### The subtlety that matters most

**Firestore TTL deletion is not immediate.** Google documents a lag of up to 24 hours between the expiry timestamp and the document actually disappearing.

So **TTL is housekeeping, not enforcement.** The BFF must check `absolute_expires_at` and `last_seen_at` on **every** read and reject an expired session itself. A design that relies on TTL to end sessions has sessions living up to a day past their stated lifetime.

---

## 5. A correction to the session design in `11` §5.2

`11` §5.2 says the access and refresh tokens are "envelope-encrypted with a Cloud KMS key". Read literally — a KMS decrypt call per session read — that is wrong, for two reasons: it adds a network round trip and 10 to 30 ms to **every API request**, and it consumes KMS cryptographic operations quota at the rate of your total request volume.

**Envelope encryption done properly avoids both.** Generate a data encryption key, use it to encrypt the tokens, and have KMS wrap only the data encryption key. The instance caches the unwrapped data key in memory for its lifetime, so KMS is called on instance start and on key rotation — not per request.

Simplest correct options, in order of preference:

1. **Cached data encryption key**, wrapped by KMS, rotated on a schedule. KMS calls become rare.
2. **Firestore CMEK alone**, with no application-level encryption. The database is already encrypted with your key; the additional layer protects only against a database export by someone who has read access but not KMS access. Decide whether that threat is in scope.

Option 2 is defensible for a dev platform. Option 1 is right if a token in a database export is considered a real risk. **What is not acceptable is a KMS round trip per request** — measure it before shipping either way.

---

## 6. O10 — Limits and quotas inventory

The ones that can actually bite this platform. Check current values before go-live; several are adjustable on request, and requests take time.

### Apigee

| Limit | Why it matters here |
|---|---|
| Request and response payload size | Document translation through the gateway. Confirm the ceiling and use `gs://` URIs |
| Key value map entry size and count | The group-to-business-unit and model allow-list maps |
| Cache entry size and total cache | Any caching you add later |
| Proxy deployment units per environment | Two proxies today, not a near-term concern |
| PSC network endpoint group connections per project to an instance | 100 |
| Message processor count | Affects `SpikeArrest` if `UseEffectiveCount` is ever removed |

### Model Armor

| Limit | Value |
|---|---|
| API queries per minute per project | 1,200 — and screening a prompt plus its response is two calls, so roughly **600 screened model calls per minute** |
| Tokens per filter | 10,000 for injection, jailbreak, responsible AI and CSAM |
| Tokens, sensitive data filter | 130,000 |
| Input size | 4 MB, above which content is skipped entirely |

### Vertex AI

| Limit | Why |
|---|---|
| Queries and tokens per minute, per project per region per model | Pooled across every usecase now that they share one project. One runaway service starves the others |
| Vector Search index size, replicas, concurrent queries | Minimum two replicas, so a restart is not an outage |

### Cloud Run

| Limit | Value or note |
|---|---|
| Direct VPC egress addresses | ~2 per instance steady, 4× peak during rollout. **127 instances total** across all services |
| Maximum instances per service beyond 100 | Quota-controlled |
| Request timeout | 3,600 s maximum. 600 s for the API services, 3,600 s for the worker |
| Concurrency per instance | Affects how many instances you need, and therefore addresses |

### Firestore

| Limit | Why it matters |
|---|---|
| **Sustained writes to a single document: about 1 per second** | The session document is written on every refresh and on `last_seen_at` updates. **Do not write `last_seen_at` on every request** — throttle it to once per minute, or you will hit this on an active session |
| Document size | 1 MiB. Not a concern if the session document stays small, which §4 requires anyway |
| TTL deletion lag | Up to 24 hours. See §4 — TTL is housekeeping, not enforcement |
| Transaction contention | Relevant to the refresh lease in §3. Keep the transaction short |

The single-document write limit is the one most likely to surprise. It is the reason `last_seen_at` needs throttling rather than a naive write per request.

### Cloud Tasks

| Limit | Note |
|---|---|
| Task payload size | Keep the job identifier in the task and the detail in Firestore |
| Maximum dispatch rate and concurrent dispatches | Set deliberately — this is the backpressure control for translation |
| Maximum retry duration and attempts | Interacts with quota exhaustion returning 429 |

### Cloud KMS

| Limit | Why |
|---|---|
| Cryptographic operations per second | Directly relevant to §5. A KMS call per request consumes this at your full request rate |

### Networking

| Limit | Note |
|---|---|
| One active proxy-only subnet per region per VPC | Both load balancers share it |
| PSC endpoints per VPC, subnets per VPC, firewall rules per VPC | Comfortable today, worth knowing |

### IAP

| Limit | Note |
|---|---|
| Session duration | 8 hours, aligned with the application session |
| Latency | Google states IAP increases latency. Paid twice per request in this design — at the front door and again at the backend |

---

## 7. What changed in other documents

| Document | Change |
|---|---|
| `11` §5.2 | The envelope-encryption wording is corrected by §5 above. A KMS call per request is not the intent |
| `11` §5.2 | `last_seen_at` must be throttled — Firestore's single-document write limit |
| `09` §19.4 | The BFF requirements list gains logout, rotation, the refresh lease and fail-closed behaviour |
| `12` | O6 to O10 move from open to settled |
