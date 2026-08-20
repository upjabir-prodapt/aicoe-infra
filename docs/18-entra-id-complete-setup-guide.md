# 18 — Entra ID Sign-In: Complete Beginner's Setup Guide (Microsoft + GCP + Terraform)

**Audience:** you have never set up an Entra app registration, a Google Workforce Identity Pool, or touched this Terraform repo before. Every step tells you exactly where to click or what to type. No prior context assumed.

**What you will build, in one sentence:** a Colt employee signs into Microsoft Entra ID once, and that identity flows through Google Cloud (via Workforce Identity Federation + Identity-Aware Proxy) all the way to the AI Hub UI and its backend APIs — the employee never creates or uses a Google account.

**Relationship to other docs in this repo:**
- `15-entra-gcp-iap-setup.md` is the deep-dive reference for the identity design (why two app registrations, why groups vs. roles, the full sign-in sequence diagram, Apigee policy detail, troubleshooting table). **Read this document first if you just want to get a working system end-to-end; go to `15` when you need the "why" behind a step or hit a problem not covered here.**
- `16-terraform-staged-deployment.md` is the authoritative guide for running the numbered Terraform stages (`0-bootstrap` through `7-apigee-runtime`). This guide tells you **which stage** each Entra-related resource lives in and when to run it — it does not replace `16`'s command reference.
- `09-implementation-runbook-console.md` covers the rest of the platform build (network, Apigee org, logging) that has nothing to do with Entra ID.
- `19-department-companyname-claim-options.md` is a focused side-document for one specific sub-problem in §3.2 below: Entra's optional-claims picker does not offer `department`/`companyName`, and this document walks through the two working alternatives.


**Order of operations — the golden rule:** Microsoft Entra pieces and Google Cloud pieces depend on each other in *both* directions. You cannot finish the Entra side in one sitting and then move to Google — you will go back and forth twice. This guide is written in the exact order that avoids getting stuck, with a clear "come back here later" flag every time that happens.

---

## 0. Before you start — what you need

| Requirement | Why |
|---|---|
| **Application Administrator** or **Cloud Application Administrator** role in Microsoft Entra ID | To create app registrations and manage groups |
| **`roles/iam.workforcePoolAdmin`** at the GCP **organization** level | To create the Workforce Identity Pool (org-level resource, not project-level) |
| Access to run Terraform against this repo, per `16-terraform-staged-deployment.md` §6 (ADC login, or CI) | To apply the GCP-side resources that are managed as code |
| `gcloud` CLI installed and authenticated | For a couple of one-off commands (service agent creation, secret upload) |
| Someone who can add people to Entra security groups (often the same admin, sometimes a separate service-desk team) | Ongoing access management after setup |

**Two environments, never shared.** Everything below uses Dev naming (`gclt-aicoe-dev-*` projects, tenant ID `f820f6ca-864c-41c0-b2aa-49527f91cc4a`, dev hostnames). When you repeat this for Prod: create a **separate pair of Entra app registrations**, a **separate client secret**, and use the Prod project IDs. Never reuse a Dev app registration, client secret, or workforce pool in Prod.

---

## 1. The big picture — three systems, one identity

```
Microsoft Entra ID                 Google Cloud                          Apigee
──────────────────                 ────────────────────────              ──────────────────
App registration                   Workforce Identity Pool               VerifyJWT policy
 "AI-BFF"          ──trusts──►      "colt-aiappsui-auth"                 reads the token AI-BFF
 (confidential                      + OIDC provider "entra"               forwards, checks
  client, does                                                            issuer + audience +
  sign-in)                          IAP on "bs-aihub-bff"                 App Role
                                    (front door — authenticates
App registration                    the PERSON)
 "AI-API"          ──issues───►
 (defines App Roles,                Cloud Run IAM on backend
  Translation.User /                services (translation, sales)
  SalesAgent.User /                 (authenticates the MACHINE
  Platform.Admin)                    calling on the last hop)

Security groups    ──map to──►     IAP-secured Web App User
 (who gets which                    binding, one per group
  App Role)
```

**Two separate token exchanges happen with Entra, not one:**
1. **IAP's own federation login** — the interactive sign-in the user sees, done through the Workforce Identity Pool. This is what gets the person past the front door of the load balancer.
2. **The BFF's own OIDC flow** — a second, mostly-silent exchange the AI Hub UI's backend (`aihub-bff` on Cloud Run) performs directly against Entra ID, using its own confidential client credential, to get an access token containing the user's App Roles. This is what Apigee later checks to decide what the user may call.

If you remember nothing else: **IAP proves who you are at the door. Apigee's JWT check, using the BFF's separate token, decides what you can do once inside.**

---

## 2. Environment variables and Terraform touchpoints you'll be filling in

Keep this table open — every step below produces one of these values.

| Name | Where it's used | Produced in |
|---|---|---|
| `ENTRA_TENANT_ID` | AI-Hub-UI `server/config/env.ts`, Cloud Run env var | Entra tenant Overview page (§3.1) |
| `ENTRA_CLIENT_ID` | Same | `AI-BFF` app registration Overview page (§3.3) |
| `ENTRA_REDIRECT_URI` | Same | You decide it, then register it in Entra (§3.3) |
| `ENTRA_CLIENT_SECRET_SECRET_NAME` | Same — this is a **Secret Manager secret name**, not the secret value itself (default `entra-bff-client-secret`) | Already created by Terraform stage `2-foundations` (§4.2); you upload the real value (§5) |
| `ui_user_group` (Terraform variable, `envs/dev/terraform.tfvars`) | Stage `6a-aihub-ui`, feeds the IAP principal binding | `App-AICoE-UI-Users` group's **Object ID** in Entra (§3.4) |
| `workforce_pool` (Terraform variable) | Same stage | You choose it (`colt-aiappsui-auth`), created manually in Google Cloud console (§6) |
| Workforce pool provider's redirect URI | Registered back into `AI-BFF` app registration | Shown by Google's console once the pool/provider exist (§6.3) — **this is one of the "come back to Entra" moments** |

---

## 3. Part A — Microsoft Entra ID setup

Do this first because the Google side (Workforce Identity Pool) needs values — issuer URL, client ID, client secret — that only exist once these app registrations are created.

### 3.1 Find your tenant ID

1. Go to the [Entra admin center](https://entra.microsoft.com).
2. **Identity → Overview**. Your **Tenant ID** is shown at the top (a GUID like `f820f6ca-864c-41c0-b2aa-49527f91cc4a`). Copy it — this becomes `ENTRA_TENANT_ID`.

### 3.2 Create `AI-API` first — the resource app (defines entitlements)

Build this one first because its App Roles must exist before `AI-BFF` can request them.

1. **Identity → Applications → App registrations → + New registration**.
2. Name: `AI-API`.
3. Supported account types: **Accounts in this organizational directory only (Single tenant)**.
4. Redirect URI: leave blank — nobody signs into this app directly.
5. Click **Register**.

**Set the Application ID URI (its "address" for token audience purposes):**

6. In `AI-API`, go to **Expose an API**.
7. Click **Set** next to Application ID URI. Entra will pre-fill a suggested value like `api://<client-id-guid>`.

> **If you try to change it to a plain string like `api://aicoe-platform` and get:**
> ```
> Failed to add identifier URI api://aicoe-platform. All newly added URIs must contain a
> tenant verified domain, tenant ID, or app ID, as per the default tenant policy of your
> organization. If the requestedAccessTokenVersion is set to 2, this restriction may not
> apply.
> ```
> **this is a tenant-wide security policy, not a mistake in this guide** — most Entra tenants (including Colt's) block "vanity" Application ID URIs that don't derive from something Entra can prove your org actually owns. You have three ways around it, in order of how commonly they're actually usable:
>
> | Option | What to enter | Trade-off |
> |---|---|---|
> | **A — use the App ID (recommended, always works)** | `api://<AI-API's own Application (client) ID>`, e.g. `api://f82163b4-4b5f-4ce9-86bc-5bb5d2f6280b` — this is exactly what Entra pre-filled before you edited it | Not as readable, but requires no admin/domain changes and always passes this policy. **This is what the rest of this guide assumes unless you tell it otherwise.** |
> | **B — use a verified domain** | `api://aicoe-platform.colt.net` (only if `colt.net`, or a subdomain you register, is a **verified custom domain** on this Entra tenant — check **Identity → Custom domain names**) | Readable, but needs a verified domain added to the tenant first — usually a separate change only a tenant admin can make |
> | **C — use the tenant ID** | `api://<your tenant ID>/aicoe-platform` | Works immediately, but ties the URI to the tenant ID (fine for a single-tenant app, which `AI-API` is) |
>
> **Whichever you choose, that exact string replaces every occurrence of `api://aicoe-platform` for the rest of this guide** — in the scopes below, in `server/entra/oidcClient.ts`'s hardcoded scope strings (§9), and in Apigee's Verify JWT audience check (§11). Pick it once here and keep it identical everywhere else; a mismatch anywhere in that chain breaks the token exchange or the audience check.

8. Click **Save** once you've settled on the value.
9. Click **+ Add a scope**. You must create **three** delegated permission scopes here, not just one — the AI-Hub-UI codebase's OIDC client (`server/entra/oidcClient.ts`) requests all three by name in every authorization and token request, and Entra will reject the request with `invalid_scope` if any of them doesn't exist on this app registration:


| Scope name | Admin consent display name | Admin consent description |
|---|---|---|
| `access_as_user` | Access AI CoE platform as the signed-in user | Allows the application to call AI CoE APIs on behalf of the signed-in user. |
| `Translation.Translate` | Use the Translation service as the signed-in user | Allows the application to call the Translation API on behalf of the signed-in user. |
| `Sales.Research` | Use the Sales Agent research service as the signed-in user | Allows the application to call the Sales Agent research API on behalf of the signed-in user. |

For each: Who can consent: **Admins and users**, State: **Enabled**, then click **Add scope**.

> **Don't confuse these with the App Roles below.** `access_as_user`, `Translation.Translate`, and `Sales.Research` are **delegated permission scopes** — requested in the `scope=` parameter of the authorization URL, and granted per sign-in via (or without, once admin consent is granted) a consent prompt. The App Roles created next (`Translation.User`, `SalesAgent.User`, `Platform.Admin`) are a **completely different mechanism** — they are assigned to users/groups ahead of time and appear automatically in the token's `roles[]` claim; they are never requested via `scope=`. Both exist side by side in this design: the scopes let the BFF's confidential client actually mint a token in the first place, while the App Roles are what Apigee's Verify JWT policy checks afterwards to decide what that token's holder may call. Skipping either one breaks a different part of the flow — a missing scope breaks the token exchange itself (§6, §9), a missing/misassigned App Role breaks Apigee's authorization check (§11) while sign-in still succeeds.


**Define the three App Roles** (these become the `roles[]` claim Apigee checks later):

9. Go to **App roles → + Create app role**. Repeat three times:

| Display name | Value | Allowed member types | Description |
|---|---|---|---|
| Translation User | `Translation.User` | **Users/Groups** | Access to `/api/translation/*` |
| Sales Agent User | `SalesAgent.User` | **Users/Groups** | Access to `/api/sales/*` |
| Platform Admin | `Platform.Admin` | **Users/Groups** | Access to administrative endpoints |

For each, set Allowed member types to **Users/Groups** (not Applications) — this is what lets you assign a security group to the role instead of individual users.

**Add optional claims** (used later for reporting/quota dimensions):

10. **Token configuration** is a blade on the **App registration** itself (`AI-API`), not on its Enterprise Application object — the two are different views of the same underlying app in Entra, and this menu item only appears on the App registration side. Confirm you're there: **Identity → Applications → App registrations → AI-API** (not **Enterprise applications → AI-API**). In the left-hand nav under **Manage**, click **Token configuration**.

> **If you still don't see "Token configuration" in the left nav:** this is most commonly one of:
> - You're viewing the **Enterprise application** object instead of the **App registration** — go back via **App registrations**, not **Enterprise applications**, and search for `AI-API` there.
> - Your Entra role doesn't have rights to configure this app's token claims — you need **Application Administrator**, **Cloud Application Administrator**, or to be an **owner** of this specific app registration (added under **Owners** on the app registration's Overview page). Being a Global Reader or a plain user is not enough.
> - Menu labels shift slightly between Entra portal versions/tenant configurations — if "Token configuration" isn't visible but "Manifest" is, the groups claim below can also be added by editing the underlying app manifest directly (`groupMembershipClaims` JSON key) — this achieves the same result via a different UI path and is a reasonable fallback if the blade is genuinely missing for your tenant/version.

11. Click **+ Add optional claim**, Token type **Access**, and look for `department` and `companyName` in the list.

> **You will not find them there — and that's expected, not a mistake.** Entra's optional-claims picker only offers a fixed, built-in set of token claims — it is not a way to project arbitrary Microsoft Graph user profile properties (which is what `department`/`companyName` actually are) into a token. **See `19-department-companyname-claim-options.md` for the full explanation.** This platform uses **Option A (Microsoft Graph call after sign-in)**, and it is already implemented in the AI-Hub-UI codebase — nothing further to do here in Entra beyond what §3.3 already covers (the `User.Read` permission). Skip clicking "Add" for `department`/`companyName` in this picker, since there's nothing to select, and continue to the groups claim below.
>
> **What Option A's implementation looks like, for reference:**
> - `server/entra/oidcClient.ts` requests the `User.Read` delegated scope alongside the platform scopes, and exposes `getDepartmentAndCompany(accessToken)`, which calls `GET https://graph.microsoft.com/v1.0/me?$select=department,companyName` and fails open with placeholder values if Graph is unreachable.
> - `app/auth/callback/route.ts` calls `getDepartmentAndCompany()` right after the token exchange and stores the result in the session document (`server/session/sessionStore.ts`'s `UserSession.department` / `UserSession.companyName` fields) — not from the JWT.
> - `app/auth/session/route.ts` returns `companyName` alongside `department` to the frontend, so the UI can display it if needed.
> - Both proxy routes (`app/api/translation/v1/[...path]/route.ts` and `app/api/sales/v1/[...path]/route.ts`) inject `x-colt-user-company` as a trusted header when forwarding requests to Apigee, the same pattern already used for `x-colt-user-id` (`oid`) and `x-colt-user-department`. This is the header-injection approach flagged in `19` §3.4 as the way to get `department`/`companyName` to Apigee even though they aren't in the forwarded JWT itself.



**Scope the groups claim** (important — avoids a group-overflow bug later):

12. Still on the same **Token configuration** blade for `AI-API` → **+ Add groups claim**. Choose **Groups assigned to the application**, tick both ID and Access tokens. This keeps the emitted groups list small regardless of how many other Colt groups a user belongs to. Unlike `department`/`companyName` above, **groups is a genuine, built-in optional claim** and will appear in the standard token configuration UI without any workaround.



### 3.3 Create `AI-BFF` — the confidential client app (does the sign-in)

1. **App registrations → + New registration**.
2. Name: `AI-BFF`.
3. Supported account types: **Single tenant**.
4. Click **+ Add a platform → Web** (NOT "Single-Page Application" — a SPA can't hold a secret and would push tokens into browser JavaScript, breaking the design where the browser only ever sees an opaque session cookie).
5. Redirect URI: `https://aihub.aicoe-dev-int.colt.net/auth/callback` (Dev). This becomes `ENTRA_REDIRECT_URI`. For local development, also add `http://localhost:8080/auth/callback` as a second Web redirect URI.
6. Also add a **Front-channel logout URL**: `https://aihub.aicoe-dev-int.colt.net/auth/logout` (under **Authentication**).
7. Under **Authentication → Implicit grant and hybrid flows**, leave **both boxes unchecked**.
8. Click **Register**.
9. On the **Overview** page, copy the **Application (client) ID** — this becomes `ENTRA_CLIENT_ID`.

**Create the client credential (the secret Terraform/Secret Manager will hold):**

10. Go to **Certificates & secrets**.
11. Preferred: upload a **certificate** if your PKI process supports it (no expiry surprises, nothing secret travels over the wire). Otherwise:
12. **Client secrets → + New client secret**. Set expiry (24 months max recommended, put a calendar reminder before it lapses). Click **Add**.
13. **Copy the secret VALUE immediately** — Entra shows it exactly once. Paste it somewhere safe temporarily (a password manager, not a chat message or ticket) — you'll upload it to GCP Secret Manager in §5.

**Request the API permissions and grant admin consent:**

14. **API permissions → + Add a permission → My APIs → AI-API**.
15. Select **Delegated permissions**, check **all three** boxes — `access_as_user`, `Translation.Translate`, `Sales.Research` — click **Add permissions**. Missing any one of these here is the single most common way to break this setup: the OIDC client code requests all three every time (see §9), so `AI-BFF` needs permission to ask for all three, not just one.
16. **Also add `User.Read`**: **+ Add a permission → Microsoft Graph → Delegated permissions**, search for and check `User.Read`. This is what makes it possible for the callback route to fetch `department`/`companyName` from Graph after sign-in (§3.2's optional-claims workaround, implemented as `getDepartmentAndCompany()` in `server/entra/oidcClient.ts` — see `19-department-companyname-claim-options.md` §3 for the full picture). `User.Read` is often already listed by default on a new app registration — verify it's there rather than assuming; add it if not.
17. Click **Grant admin consent for Colt** and confirm — this covers all four permissions above in one click. (Skipping this makes every user see a consent screen on first sign-in — confusing and support-ticket-generating.)



### 3.4 Create the four security groups

**Groups → New group** (type: **Security**), create:

| Group name | Purpose |
|---|---|
| `App-AICoE-UI-Users` | Front-door access only. Carries **no App Role** — used only for the IAP binding in §7 |
| `App-AICoE-Translation-Users` | Gets the `Translation.User` App Role |
| `App-AICoE-SalesAgent-Users` | Gets the `SalesAgent.User` App Role |
| `App-AICoE-Platform-Admins` | Gets the `Platform.Admin` App Role |

**Assign the three role-bearing groups to their App Roles:**

1. Go to `AI-API` → click the linked **Enterprise application** (not the app registration itself) → **Users and groups → + Add user/group**.
2. For each of the three groups: select the group, select the matching App Role, click **Assign**.
3. `App-AICoE-UI-Users` does **not** get an App Role assignment here — it's only referenced later as a Google IAM principal (§7).

**Add people to each group** (**Groups → [name] → Members**). Note: anyone in an entitlement group (e.g. Translation) should also be in `App-AICoE-UI-Users` — front-door access and entitlement are two separate checks, and being in the entitlement group alone won't get someone past IAP.

4. **Copy the Object ID of `App-AICoE-UI-Users`** (Groups → the group → Overview → Object Id). You will need this exact value **twice**: once for the Terraform variable `ui_user_group` (§8), and once as a fallback if you ever bind IAP manually.

### 3.5 Checkpoint — you now have everything Google needs to start

At this point you have:
- Tenant ID
- `AI-BFF` client ID + client secret (or certificate)
- `App-AICoE-UI-Users` Object ID

**Stop here and move to Part B.** You will come back to Entra once more in §6.4 to register a redirect URI Google's console gives you.

---

## 4. Part B — Google Cloud: enable APIs and confirm the Terraform-managed pieces

### 4.1 Enable required APIs (if not already enabled)

Most of this is already codified in Terraform stage `2-foundations` (see `terraform/2-foundations/gclt-aicoe-dev-aihub-ui.tf`), which enables `secretmanager.googleapis.com`, `iap.googleapis.com`, `cloudkms.googleapis.com`, `run.googleapis.com`, and more, and forces their service agents into existence. If you are running against a fresh project that hasn't had stage `2-foundations` applied yet, run that stage first — see `16-terraform-staged-deployment.md` §10.3.

You additionally need, at the **organization** level (not managed by this Terraform — a one-time manual console step):

| API | Where |
|---|---|
| **Identity-Aware Proxy API** | project `gclt-aicoe-dev-aihub-ui` (already enabled by stage `2-foundations`) |
| **Workforce Identity Federation** | Organization-level feature, enabled implicitly the first time you create a pool |

### 4.2 What Terraform already creates for you (no manual step needed here)

Confirm these exist by looking at the referenced files — you don't need to create them by hand:

- **Two empty Secret Manager secrets**, `entra-bff-client-secret` and `apigee-bff-client-key`, created in `terraform/2-foundations/gclt-aicoe-dev-aihub-ui.tf` (`google_secret_manager_secret.gclt_aicoe_dev_aihub_ui_bff`), encrypted with a customer-managed KMS key. **Terraform creates the secret container, but not a value inside it** — that's a manual upload, see §5.
- **The `aihub-bff-sa` service account** for the Cloud Run BFF service.
- **The IAP-enabled backend service** `bs-aihub-bff` and its Cloud Run invoker binding for the IAP service agent, created in stage `6a-aihub-ui` (`terraform/6-workloads/6a-gclt-aicoe-dev-aihub-ui/main.tf`). This stage is what actually wires the Workforce Identity Pool group into an IAP grant — covered in §8 below.

If stage `2-foundations` has not yet been applied for your project, do that now per `16-terraform-staged-deployment.md` §10.3, before continuing.

---

## 5. Upload the Entra client secret into GCP Secret Manager

The secret **container** already exists (created by Terraform, §4.2). You now add the actual value you copied in §3.3 step 13.

**Option A — gcloud (recommended, one command):**

```bash
echo -n "PASTE_THE_ENTRA_CLIENT_SECRET_VALUE_HERE" | \
  gcloud secrets versions add entra-bff-client-secret \
  --project=gclt-aicoe-dev-aihub-ui \
  --data-file=-
```

**Option B — console:** Google Cloud console → **Security → Secret Manager** → `entra-bff-client-secret` → **+ New version** → paste the value → **Add new version**.

**Verify it landed:**

```bash
gcloud secrets versions access latest \
  --project=gclt-aicoe-dev-aihub-ui \
  --secret=entra-bff-client-secret
```

This should print the same secret value back. **Never** put this value in a `.tfvars` file, a `.env` file that gets committed, or a container image — the whole design point of this secret living in Secret Manager is that it's fetched at runtime by `server/secrets/gcpSecretManager.ts` in the AI-Hub-UI app, never baked in anywhere.

---

## 6. Part B continued — create the Workforce Identity Pool (manual, org-level, not Terraform)

This is the Google-side trust anchor that lets Entra ID authenticate people for Google-protected resources without those people ever having a Google account. **This is an organization-level resource and is deliberately not managed by this Terraform repo** — it's created once, by hand, per the design record.

### 6.1 Create the pool

1. In the Google Cloud console, search for **Workforce Identity Federation** and open it.
2. Confirm the resource picker at the top shows your **organization** (not a project) — workforce pools don't appear as an option under a project.
3. Click **+ Create Pool**.

| Field | Value |
|---|---|
| Name | `colt-aiappsui-auth` |
| Pool ID | `colt-aiappsui-auth` |
| Description | Entra ID sign-in for AI CoE applications |
| Session duration | 8 hours to start |

4. Click **Continue** to add a provider.

### 6.2 Add the OIDC provider pointing at Entra

| Field | Value |
|---|---|
| Provider type | **OpenID Connect (OIDC)** |
| Provider name | `entra` |
| Issuer (URL) | `https://login.microsoftonline.com/<YOUR_TENANT_ID>/v2.0` |
| Client ID | The `AI-BFF` app registration's **Application (client) ID** from §3.3 |
| Client secret | The same value from §3.3 step 13 |
| Response type | `Code` |

5. Click **Next** to the attribute mapping screen.

### 6.3 Configure attribute mapping

This translates Entra's token claims into something Google IAM understands.

| Google attribute | Entra claim |
|---|---|
| `google.subject` | `assertion.sub` |
| `google.groups` | `assertion.groups` |
| `attribute.department` | `assertion.department` |
| `attribute.organization` | `assertion.companyName` |

Enter each row exactly, click **Save**.

### 6.4 Come back to Entra — register Google's redirect URI

6. Once saved, the provider's detail page shows a **redirect URI** Google expects Entra to send users back to. It looks like:
   ```
   https://iam.googleapis.com/v1/projects/.../locations/global/workforcePools/colt-aiappsui-auth/providers/entra:...
   ```
   **Copy it exactly.**
7. Go back to Entra admin center → `AI-BFF` app registration → **Authentication → + Add a platform** (or edit the existing Web platform) → add this as an additional **Redirect URI**. Save.

### 6.5 Verify the pool shows no warnings

8. Return to the pool's detail page in Google Cloud console. It should show provider `entra` with **no configuration warnings**. A warning here usually means a typo in the issuer URL, or you haven't done step 6.4 yet.
9. Full end-to-end sign-in testing isn't possible until IAP is wired up in §8 — a clean, warning-free pool is all you can confirm right now.

---

## 7. Terraform variables: tell Terraform which group and pool to bind

Open `terraform/envs/dev/terraform.tfvars` in this repo. You'll see:

```hcl
workforce_pool = "colt-aiappsui-auth"
ui_user_group  = "REPLACE_ME"
```

Replace `REPLACE_ME` with the **Object ID** of `App-AICoE-UI-Users` you copied in §3.4 step 4:

```hcl
workforce_pool = "colt-aiappsui-auth"
ui_user_group  = "3f2b1c9a-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

Do **not** commit real tenant secrets here — this variable is a group Object ID, not a secret, so it's fine in `terraform.tfvars`. The actual client secret never goes in this file (it lives only in Secret Manager, per §5).

---

## 8. Apply Terraform stage `6a-aihub-ui` — this is what actually wires Entra into IAP

This is the stage that reads `workforce_pool` and `ui_user_group` and creates the real IAP binding. Follow `16-terraform-staged-deployment.md` §10.7 exactly; summarized here for convenience:

```bash
cd terraform/6-workloads/6a-gclt-aicoe-dev-aihub-ui
terraform init -reconfigure \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="prefix=6-workloads/6a-gclt-aicoe-dev-aihub-ui"

terraform plan \
  -var-file="../../envs/dev/terraform.tfvars" \
  -var-file="../../envs/dev/stages/6a.tfvars" \
  -out=tfplan

# Review the plan. You should see:
#  - google_compute_region_network_endpoint_group.neg  (create)
#  - google_compute_region_backend_service.bs           (create, iap { enabled = true })
#  - google_iap_web_backend_service_iam_member.accessor  (create, member = principalSet://.../group/<ui_user_group>)
#  - google_cloud_run_v2_service_iam_member.iap_invoker  (create, IAP service agent gets run.invoker)

terraform apply tfplan

mkdir -p ../../vars-handoff
terraform output -json | jq 'map_values(.value)' > ../../vars-handoff/6a-gclt-aicoe-dev-aihub-ui.auto.tfvars.json
```

**Precondition:** the `aihub-bff` Cloud Run service must already be deployed (via the application's own CI pipeline) before this stage's Network Endpoint Group can bind to it — see the troubleshooting table in `16-terraform-staged-deployment.md` §9 ("Cloud Run NEG binding fails").

**What this stage does, tying back to Part A/B above:**
- Creates `bs-aihub-bff`, the backend service with IAP switched on — this is the front door.
- Grants `App-AICoE-UI-Users` (via its Object ID, wrapped in the `principalSet://iam.googleapis.com/locations/global/workforcePools/colt-aiappsui-auth/group/<id>` format) the **IAP-secured Web App User** role — this is the only group that needs an IAP grant.
- Grants the IAP service agent `roles/run.invoker` on the `aihub-bff` Cloud Run service. **Skipping this produces the single most common symptom: users sign in successfully, then get a 403.** Terraform does this for you automatically, but if you ever do this by hand, the commands are in `15-entra-gcp-iap-setup.md` §B.8.

---

## 9. Set the AI-Hub-UI application's environment variables

The AI-Hub-UI Next.js app (`server/config/env.ts`) reads these at runtime. Set them as Cloud Run `--set-env-vars` in your deployment pipeline (see that repo's `docs/deployment.md` and `.gitlab-ci.yml`), or in `.env.local` for local development:

```bash
ENTRA_TENANT_ID=<tenant ID from §3.1>
ENTRA_CLIENT_ID=<AI-BFF client ID from §3.3>
ENTRA_REDIRECT_URI=https://aihub.aicoe-dev-int.colt.net/auth/callback
ENTRA_CLIENT_SECRET_SECRET_NAME=entra-bff-client-secret
GCP_PROJECT_ID=gclt-aicoe-dev-aihub-ui
GCP_PROJECT_NUMBER=<gcloud projects describe gclt-aicoe-dev-aihub-ui --format='value(projectNumber)'>
GCP_KMS_KEY_RING=aihub-ew3
GCP_KMS_KEY_NAME=session
GCP_KMS_LOCATION=europe-west3
```

Note `ENTRA_CLIENT_SECRET_SECRET_NAME` is the **name** of the Secret Manager secret (`entra-bff-client-secret`), not the value — the app fetches the value at runtime via `server/secrets/gcpSecretManager.ts`, using the project's own service account permissions. The BFF's own OIDC scopes are hardcoded in `server/entra/oidcClient.ts`:

```
openid profile offline_access User.Read api://aicoe-platform/Translation.Translate api://aicoe-platform/Sales.Research
```

`User.Read` is what lets the callback route fetch `department`/`companyName` from Microsoft Graph (§3.2, `getDepartmentAndCompany()` — see `19-department-companyname-claim-options.md`).

**`api://aicoe-platform` here is a placeholder for whatever Application ID URI you actually landed on in §3.2** — if your tenant's policy forced you onto Option A (`api://<AI-API's client ID GUID>`) or Option C (`api://<tenant ID>/aicoe-platform`), you must edit `server/entra/oidcClient.ts` in the AI-Hub-UI codebase (the three occurrences of `api://aicoe-platform` in `getAuthorizationUrl`, `exchangeCodeForTokens`, and `refreshAccessToken`) to use that exact real value instead, and redeploy the app, before sign-in will work. The literal string `api://aicoe-platform` only works as-is if your tenant happens to allow vanity identifier URIs (uncommon) or if you registered `aicoe-platform` as part of a verified domain (Option B). A mismatch here — code says one URI, Entra has another — fails with an invalid-scope error identical to a missing scope, so if you hit that error after already creating all three scopes, re-check this file matches §3.2's final choice exactly.



---

## 10. Front-door load balancer (ingress) — brief pointer

The `bs-aihub-bff` backend service created in §8 needs a load balancer frontend pointing at it, built in project `gclt-aicoe-dev-ingress` (Terraform stage `6c-ingress`). This is networking, not identity — full detail is in `15-entra-gcp-iap-setup.md` §B.9 and `16-terraform-staged-deployment.md`'s stage inventory. In short: an internal, regional Application Load Balancer, HTTPS frontend, routed to `bs-aihub-bff`. A TLS certificate trusted by client browsers is required — a publicly issued certificate validated by DNS is the simplest option for an internal hostname.

---

## 11. Apigee — verify the Entra token and enforce the App Role

By the time a request reaches Apigee, IAP has already let the person through the front door, and the BFF has separately completed its own token exchange with Entra to get an access token containing `roles[]`. Apigee's job is to check that token and enforce the App Role.

**Where:** Google Cloud console → Apigee, project `gclt-aicoe-dev-apigee` (built by Terraform stage `4-apigee`; the proxy configuration itself is applied via `apigeecli` in the `proxies` CI stage, not raw Terraform — see `16-terraform-staged-deployment.md` §5.1).

Policy chain, in order:

| # | Policy | Configuration |
|---|---|---|
| 1 | Spike Arrest | Keyed on `oid`, runs before any credential check |
| 2 | **Verify JWT** | JWKS URI: `https://login.microsoftonline.com/<TENANT_ID>/discovery/v2.0/keys` · Issuer: `https://login.microsoftonline.com/<TENANT_ID>/v2.0` · Audience: **the exact Application ID URI you settled on in §3.2** (`api://aicoe-platform` if usable, otherwise `api://<AI-API client ID>` or `api://<tenant ID>/aicoe-platform`) |
| 3 | Extract Variables | `oid`, `roles`, `preferred_username`, `department` from the verified token |

| 4 | Raise Fault (403) | If the App Role required for the requested path is missing. Default-deny for unrecognized paths |
| 5 | Verify API Key | Resolves the API Product tied to the caller |
| 6–7 | Quota (per minute/day) | Keyed on `oid` |
| 8 | Assign Message | Strip inbound `Authorization`/`x-colt-*` headers; inject verified `oid`/`department`/`roles` as trusted headers |

Path-to-role mapping:

| Path | Required App Role |
|---|---|
| `/api/translation/*` | `Translation.User` |
| `/api/sales/*` | `SalesAgent.User` |
| anything else | denied |

Full policy XML detail and the machine-to-machine `GoogleIDToken` hop to the backend Cloud Run service is in `15-entra-gcp-iap-setup.md` §B.11 — not repeated here to avoid drift between two copies.

---

## 12. End-to-end test

1. From a machine on the corporate network (VPN/ZPA path to the internal load balancer), browse to `https://aihub.aicoe-dev-int.colt.net`.
2. **Expected:** redirect to a Microsoft sign-in page. After signing in with an account in `App-AICoE-UI-Users`, the AI Hub interface loads.
3. Try a Translation or Sales action as a user who **is** in the relevant entitlement group — should succeed.
4. Try the same action as a user who is in `App-AICoE-UI-Users` but **not** in the entitlement group — should be denied by Apigee (403), even though they got past IAP.

If something doesn't work, go to the **Common pitfalls** table in `15-entra-gcp-iap-setup.md` (bottom of that document) before assuming something in this guide is wrong — it covers the ten most common failure symptoms with their root cause and where to look.

---

## 13. Full checklist — everything in one place

**Microsoft Entra ID:**
- [ ] `AI-API` app registration exists, Application ID URI set to a value your tenant policy actually accepts (§3.2 — `api://aicoe-platform` only if your tenant allows vanity URIs; otherwise `api://<client ID>` or `api://<tenant ID>/aicoe-platform`)
- [ ] All three delegated scopes exist on `AI-API`: `access_as_user`, `Translation.Translate`, `Sales.Research`

- [ ] All three App Roles exist on `AI-API`, Allowed member types = Users/Groups
- [ ] Groups claim on `AI-API` scoped to "Groups assigned to the application"
- [ ] `department`/`companyName`: NOT set via the optional-claims picker (it doesn't offer them) — handled instead by Option A, already implemented in code (`getDepartmentAndCompany()` in `server/entra/oidcClient.ts`); see `19-department-companyname-claim-options.md`

- [ ] `AI-BFF` registered as **Web**, not SPA, implicit grant disabled
- [ ] `AI-BFF` has redirect URI(s) for the app's own callback, PLUS the Google workforce pool redirect URI (added after §6.4)
- [ ] `AI-BFF` has a client secret or certificate — value safely handed off, not left only in the portal
- [ ] `AI-BFF`'s API permissions include all three delegated scopes (not just `access_as_user`) PLUS Microsoft Graph `User.Read`, and admin consent has been granted for all four

- [ ] Four security groups exist; three assigned to their App Roles; `App-AICoE-UI-Users` has no App Role
- [ ] Real people added as members of the appropriate groups


**Google Cloud:**
- [ ] Terraform stage `2-foundations` applied — Secret Manager secrets, KMS keys, service accounts exist
- [ ] Entra client secret value uploaded into `entra-bff-client-secret` (§5)
- [ ] Workforce pool `colt-aiappsui-auth` + provider `entra` created (manual, org-level), attribute mapping matches §6.3, no warnings
- [ ] `terraform.tfvars` has the real `ui_user_group` Object ID, not `REPLACE_ME`
- [ ] Terraform stage `6a-aihub-ui` applied — `bs-aihub-bff` exists, IAP on, IAP grant + Cloud Run invoker binding present
- [ ] Load balancer (stage `6c-ingress`) routes to `bs-aihub-bff`, certificate trusted by browsers
- [ ] `aihub-bff` Cloud Run service has the right environment variables set (§9)

**Apigee:**
- [ ] Verify JWT policy checks issuer, audience matching the exact Application ID URI chosen in §3.2 (not necessarily the literal `api://aicoe-platform`), JWKS from Entra

- [ ] Path-to-role mapping enforces default-deny
- [ ] Tested (not assumed): missing role denied, expired/wrong-audience token denied, correct role allowed

**End-to-end:**
- [ ] Real sign-in works for a real Entra account in the right groups
- [ ] A user outside an entitlement group is denied that specific API, even though they pass IAP
