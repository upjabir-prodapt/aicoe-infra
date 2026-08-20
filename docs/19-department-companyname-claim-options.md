# 19 — Getting `department` and `companyName` to the BFF (Entra doesn't offer them as optional claims)

**Status: Option A is the chosen approach and is already implemented in the AI-Hub-UI codebase.** No further code changes are needed unless you specifically want Option B instead. §3 below documents what was actually built; §4 remains as a reference for Option B if you ever need it.

**Why this document exists:** `18-entra-id-complete-setup-guide.md` §3.2 walks you through Entra's **Token configuration → Add optional claim** screen and asks you to add `department` and `companyName`. When you get there, **they are not in the list.** This is expected, not a mistake — this document explains why, and gives the two real ways to get that data to the AI Hub BFF instead. Pick one, then go back to `18` and continue from where you left off.


---

## 1. Why they're not there

Entra's optional-claims picker (**App registration → Token configuration → + Add optional claim**) only offers a fixed, Microsoft-defined set of ID/access token claims — things like `email`, `upn`, `family_name`, `given_name`, `sid`, `acct`, `ctry`, `employeeid`, and a short list of others documented by Microsoft. It is **not** a general-purpose mechanism for projecting arbitrary Microsoft Entra / Microsoft Graph user profile properties into a token.

`department` and `companyName` are ordinary **Microsoft Graph user profile properties** (the same fields you'd see on `GET https://graph.microsoft.com/v1.0/me`) — a completely different mechanism from the token-claims picker. That's why they never appear there, regardless of your role, license, or tenant plan.

The **groups claim** is different — it *is* a genuine, built-in optional claim, and works exactly as described in `18` §3.2 with no workaround needed. This document is only about `department`/`companyName`.

---

## 2. The two real options

| | Option A — Call Microsoft Graph after sign-in | Option B — Directory schema extension + manifest claim |
|---|---|---|
| **What it is** | The BFF calls Graph's `/me` endpoint once, right after the token exchange, using the access token it already has | A custom directory attribute is registered in Entra, then wired into the token itself via the app's manifest |
| **Gets the value into the JWT itself?** | No — fetched separately, not part of the signed token | Yes — becomes part of the token's claim set |
| **Setup effort** | Low — one permission grant, one extra HTTP call, one small code change | Higher — requires registering a Graph extension attribute and editing the app manifest |
| **Suitable for this platform's design?** | **Yes — recommended.** `department` is explicitly documented elsewhere in this platform's design (`11-reconciled-architecture.md`) as a **reporting dimension**, not a security control. Nothing in Apigee's authorization decision depends on it, so it doesn't need to be cryptographically bound into the JWT the way `roles[]` does. | Also works, but is more setup than a reporting-only field usually justifies |
| **This document's recommendation** | **Use this one**, unless you have a specific reason to want the value inside the signed token | Only if you specifically need it inside the token (e.g. a downstream consumer that only trusts JWT claims, not a live Graph call) |

---

## 3. Option A — Call Microsoft Graph after sign-in (recommended)

### 3.1 Add the Graph permission to `AI-BFF`

1. In Entra, go to `AI-BFF` app registration → **API permissions → + Add a permission**.
2. Choose **Microsoft Graph → Delegated permissions**.
3. Search for and check **`User.Read`** (this is usually already granted by default to every app registration — verify it's listed; if not, add it).
4. Click **Add permissions**, then **Grant admin consent for Colt** if not already consented.

### 3.2 Add `User.Read` to the scopes the BFF requests

The AI-Hub-UI codebase's OIDC client (`server/entra/oidcClient.ts`) builds its `scope=` parameter from a fixed string in three places: `getAuthorizationUrl`, `exchangeCodeForTokens`, and `refreshAccessToken`. Add `User.Read` alongside the existing scopes wherever this string is defined, for example:

```
openid profile offline_access User.Read api://aicoe-platform/Translation.Translate api://aicoe-platform/Sales.Research
```

(Replace `api://aicoe-platform` with whatever Application ID URI you actually settled on — see `18` §3.2's tenant-policy note if you hit the identifier-URI error.)

### 3.3 Call Graph in the callback handler

After the authorization-code exchange succeeds (where `exchangeCodeForTokens` currently returns `access_token`/`id_token`/`refresh_token`), add a call to fetch the two profile fields:

```ts
async function fetchDepartmentAndCompany(accessToken: string): Promise<{ department: string; companyName: string }> {
  const res = await fetch(
    'https://graph.microsoft.com/v1.0/me?$select=department,companyName',
    { headers: { Authorization: `Bearer ${accessToken}` } }
  );

  if (!res.ok) {
    // Fail open with placeholders — department/companyName are reporting-only,
    // never let a Graph hiccup block sign-in.
    return { department: 'Unknown Department', companyName: 'Unknown Company' };
  }

  const profile = await res.json();
  return {
    department: profile.department || 'Unknown Department',
    companyName: profile.companyName || 'Unknown Company',
  };
}
```

Wire this into the callback flow (`app/auth/callback/route.ts` in the AI-Hub-UI codebase) right after `exchangeCodeForTokens` returns, and use its result instead of `decodeJwtClaims`'s `department` field when populating the session document (`createSession` in `server/session/sessionStore.ts`). `decodeJwtClaims` in `server/entra/oidcClient.ts` can keep decoding `oid`, `email`, and `roles` from the JWT as before — only `department` moves to this Graph-based source. `companyName` is not currently stored in the session schema; if you want it recorded, add a `companyName` field alongside `department` in `UserSession` (`server/session/sessionStore.ts`) and pass it through `createSession`.

### 3.4 What this means for the rest of the platform's design

- **GCP Workforce Identity Pool attribute mapping** (`18` §6.3) maps `attribute.department` and `attribute.organization` from `assertion.department` / `assertion.companyName` — those come from the **first** token exchange (IAP's federation login through the workforce pool), which is a separate, independent flow from the BFF's own OIDC exchange described here. If you want the workforce-pool-side attributes populated too, `department`/`companyName` would need to be emitted as **assertion claims on the ID token Entra sends during the federation login itself** — which faces the exact same optional-claims limitation described in §1 above, so the same Option A/B choice applies there as well, just on the federation login path instead of the BFF's path. If your platform's use of `attribute.department` in GCP IAM conditions is only cosmetic/logging today, you can defer this. **This has not been done** — it's a separate, still-open item if the workforce-pool side ever needs these attributes populated.
- **Apigee's Verify JWT → Extract Variables** step (`15-entra-gcp-iap-setup.md` §B.11) pulls `department` from the *BFF-forwarded* access token's claims. Since Option A does not put `department` into that token, Apigee will not see it there either. **Resolved by option (a) below — implemented in code:**
  - The BFF injects `department`/`companyName` as trusted headers when forwarding requests to Apigee, the same pattern already used for `oid`/`roles`. Specifically: `app/api/translation/v1/[...path]/route.ts` and `app/api/sales/v1/[...path]/route.ts` both set `x-colt-user-department` (pre-existing) and now also `x-colt-user-company` (added), sourced from the session document (`session.department` / `session.companyName`), which in turn came from `getDepartmentAndCompany()` at sign-in time.
  - **Follow-up needed on the Apigee side (not yet done):** if the Assign Message policy step (`15-entra-gcp-iap-setup.md` §B.11 step 8) needs to read `x-colt-user-company` specifically (it already reads/forwards `x-colt-user-department`), add it there. This is an Apigee proxy configuration change, tracked separately from the AI-Hub-UI code change described here.


---

## 4. Option B — Directory schema extension + custom claim

Use this only if you specifically need `department`/`companyName` to appear as real claims inside the signed access/ID token, not fetched separately.

### 4.1 Register a Graph directory extension attribute

1. This requires calling the Microsoft Graph API directly (there is no Entra portal UI for this) — typically via Graph Explorer or a script with an admin-consented `Application.ReadWrite.All` or `Directory.ReadWrite.All` permission.
2. `POST https://graph.microsoft.com/v1.0/applications/{AI-API's object ID}/extensionProperties` with a body such as:
   ```json
   {
     "name": "department",
     "dataType": "String",
     "targetObjects": ["User"]
   }
   ```
   Repeat for `companyName` if it isn't already exposed via the standard `companyName` Graph property (note: `companyName` is often already a standard Entra user attribute and may not need a custom extension at all — check **Entra ID → Users → [any user] → Properties → Job info** first).
3. Note the full extension property name Graph returns (it will look like `extension_<appId-no-dashes>_department`).

### 4.2 Reference it in the app manifest as an optional claim

1. Go to `AI-API` app registration → **Manifest**.
2. Find the `optionalClaims` section and add an entry under `accessToken` (and `idToken` if needed):
   ```json
   {
     "name": "extension_<appId-no-dashes>_department",
     "source": "user",
     "essential": false
   }
   ```
3. Save the manifest.

### 4.3 Consequence

The claim will now appear in the token under its extension name (not simply `department`) — update whatever parses the token (`decodeJwtClaims` in `server/entra/oidcClient.ts`, and Apigee's Extract Variables policy) to read that exact extension-prefixed claim name instead of a plain `department` key.

---

## 5. Decision checklist

- [x] Decided: **Option A** (Graph call) — chosen and implemented in code
- [ ] `User.Read` added to `AI-BFF`'s API permissions in the Entra portal, and admin-consented (§3.1 — **an Entra-side manual step, not something code can do; must be done by whoever owns the `AI-BFF` app registration**)
- [x] `User.Read` added to the scope string in all three functions in `server/entra/oidcClient.ts` (`getAuthorizationUrl`, `exchangeCodeForTokens`, `refreshAccessToken`)
- [x] `getDepartmentAndCompany()` added to `server/entra/oidcClient.ts`, called from `app/auth/callback/route.ts` right after token exchange
- [x] `UserSession.companyName` field added to `server/session/sessionStore.ts`, populated via `createSession()`
- [x] `app/auth/session/route.ts` returns `companyName` to the frontend alongside `department`
- [x] Both proxy routes (`app/api/translation/v1/[...path]/route.ts`, `app/api/sales/v1/[...path]/route.ts`) inject `x-colt-user-company` as a trusted header, alongside the pre-existing `x-colt-user-department`
- [ ] **Apigee-side follow-up (not yet done):** if the Assign Message policy needs `x-colt-user-company` specifically, add it there (`15-entra-gcp-iap-setup.md` §B.11 step 8) — separate change, outside the AI-Hub-UI codebase
- [ ] **Still open, deferred:** GCP's Workforce Identity Pool attribute mapping (`18` §6.3, `attribute.department`/`attribute.organization`) reads from the separate IAP federation login's ID token, which faces the same optional-claims limitation — not addressed by the BFF-side fix above. Revisit only if those attributes are actually consumed downstream (e.g. in a GCP IAM condition), not just cosmetic.
- [x] Return to `18-entra-id-complete-setup-guide.md` §3.2 — already updated to reference this document and describe the implemented approach

