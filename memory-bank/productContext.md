# Product Context

## Why This Project Exists
The AI CoE (Center of Excellence) requires a secure, auditable, and isolated environment in GCP to deploy AI workloads (e.g. BFF, translation APIs, sales agents). Due to strict security, compliance, and residency policies at Colt:
- Direct access to LLM endpoints (Vertex AI) must be restricted.
- An AI Gateway (Apigee) must act as a mandatory proxy for all Vertex AI calls to handle audit logging, rate limiting (Spike Arrest), and allowed-model verification.
- No workloads can have public IP addresses or route directly to the public internet.

## Problems Solved
- **Shadow AI Prevention:** Placing Apigee as a mandatory gate for Vertex AI. No workload holds direct Vertex AI user roles.
- **Data Residency & Compliance:** Auditing 100% of LLM traffic using a 400-day dedicated audit log bucket with CMEK, Log Analytics, and Linked BigQuery datasets.
- **Secure Integration:** Connects Colt's internal networks securely to serverless Cloud Run workloads using load balancers, serverless NEGs, Private Service Connect (PSC), and private DNS.

## User Experience Goals
- **Internal Seamlessness:** Developers reach standard APIs (like Translation) transparently via private load balancers, using standard TLS certificates without manual host overrides or insecure flags.
- **Robust Controls:** Clear security logging that immediately alerts on break-glass usage or public exposure.
