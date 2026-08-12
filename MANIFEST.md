# AI CoE dev platform — package manifest

**Revision R13.** Every file listed is complete. No stubs, no empty directories, no placeholders.

> **Addresses throughout this package follow the Development plan in `LLD - AICOE GCP Infrastructure v2.0.2` — the unrouted range is `192.168.4.0/22`.** The LLD is the design of record; where it and any document here disagree, the LLD wins.

## Contents

| Path | What | Size |
|---|---|---|
| `AI-CoE-Dev-Platform-Implementation-Runbook.docx` | The build runbook, 77 pages, 25 parts | 89 KB |
| `docs/` | 11 design documents | 270 KB |
| `diagrams/` | 10 diagrams — the 3 originals as PNG and SVG, plus 7 added since, including both high level architectures split for legibility | 9 MB |
| `terraform/` | 10 numbered stages + 4 modules, policy checks, pipeline. **No project factory** — projects and organisation policy are managed by the platform team in the console, not here | 80 KB |

## Read in this order

1. `LLD - AICOE GCP Infrastructure v2.0.2` — **the design of record**, Sandbox and Development
2. `docs/00-README.md` — index and settled decisions
3. `docs/11-reconciled-architecture.md` — the reconciled architecture note, narrower in scope than the LLD
4. `diagrams/dev-hla-part1.png` and `dev-hla-part2.png` — the whole platform, in two parts
5. `diagrams/aihub-signin-sequence.png` — the IAP handoff to the Backend-for-Frontend
6. `docs/09-implementation-runbook-console.md` — **the build**, or the Word version
7. `terraform/README.md` — stages, apply order, naming, ordering traps
8. `terraform/IMPLEMENTATION.md` — applying the stages from a workstation
9. `docs/14-terraform-structure-decision.md` — why the structure is what it is

## Status at a glance

| | Count | Where |
|---|---|---|
| Settled decisions | 21 | `docs/12-status-register.md` §1 — counts predate the re-addressing and have not been re-audited |
| Corrections applied | 13 | §2 |
| Specified but unverified | 9 | §3 |
| Open items | 23 | §4 |

## The three things to do first

| # | Item | Why |
|---|---|---|
| 1 | **Spike S1**, three arms, one scratch project | Decides the backend authentication mechanism, and arm 3 underpins the front door. Unverified since the first revision |
| 2 | **CSRF design** for the BFF | Required, not optional. New exposure from cookie-based sessions |
| 3 | **Certificate ownership and DNS-01 automation** | External lead time. Expiry is a total outage |

Nothing on the open list blocks runbook Parts 1 to 17. Only Parts 19 to 22 depend on the answers.

## What is not in this package

- **Cloud Run application code** — yours. Runbook §19.4 and §19.5 are the contract
- **Apigee proxy bundles and products** — deployed by `apigeecli`, not Terraform. `terraform/ci/deploy-apigee-config.sh` is the entry point
- **Organisation policies** — applied once at the folder by whoever holds `orgpolicy.policyAdmin`. Runbook Part 1
- **The Terraform state bucket** — cannot bootstrap itself. Create it by hand first

## Extraction notes

- `terraform/.gitlab-ci.yml` is dot-prefixed. It is in the archive but will not appear in a plain `ls` or in some GUI extractors
- `terraform/ci/deploy-apigee-config.sh` needs `chmod +x` after extraction; zip does not reliably preserve the executable bit
- There is no `docs/superseded/` directory. Earlier revisions of this manifest referred to one; the archived documents are not part of this package
