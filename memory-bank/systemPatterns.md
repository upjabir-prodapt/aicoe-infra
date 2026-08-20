-# System Patterns

## System Architecture
The AI CoE Dev Platform is a greenfield environment in GCP, built entirely with Terraform in numbered, isolated stages.

```
0-bootstrap → 1-org → 2-foundations → 3-network → 4-apigee → 5-network-psc → 6a/6b → 6c → 7
```

- Each stage has its own independent Terraform state in GCS.
- Stages are strictly decoupled. No stage may use `terraform_remote_state` to read outputs from another stage.
- decoupled handoffs are performed via `<stage>.auto.tfvars.json` files generated from `terraform output -json` and stored in the centralized `terraform/vars-handoff/` directory. Downstream stages automatically copy these inputs during execution.

## Networking Pattern (VPC, DNS, and PSC)
- **Private-only routing:** No public IPs on workloads. No Cloud NAT is used.
- **Unrouted IP Range:** `192.168.4.0/22` development range.
- **PSC to Google APIs:** Traffic to Google APIs uses a global Private Service Connect (PSC) endpoint (`192.168.6.144`) configured with `target = "vpc-sc"`.
- **Colt DNS Routable IP & Apigee Routing:** In Stage 5, the Private Service Connect (PSC) endpoint IP is set to `10.110.73.10` in `subnet_ew3_self_link` (the Colt-routable subnetwork) to satisfy corporate DNS registration requirements. All workloads connect to this IP, routing securely through the Shared VPC network back to Apigee in Frankfurt (`europe-west3`).
- **Regional PSC endpoints:** Regional multi-regional Google services (like Model Armor's `.rep.googleapis.com` endpoints) are not supported by the global bundle. They require:
  1. A dedicated `google_network_connectivity_regional_endpoint` resource pointed at the regional API (e.g., `modelarmor.europe-west3.rep.googleapis.com`).
  2. A dedicated, narrower Cloud DNS private zone (e.g. `modelarmor.europe-west3.rep.googleapis.com.`) which takes precedence over broader wildcard zones.
- **Shared VPC:** Managed in Stage 3. `gclt-aicoe-dev-network` is the host project, and the other 6 projects are attached as service projects.

## Security Controls
- **AI Gateway Mandatory:** All Vertex AI calls are mandated to route through Apigee. Workloads are granted no Vertex roles directly.
- **Audit Analytics:** Folder sinks route all data-access logs to a 400-day log bucket in `gclt-aicoe-dev-auditlogs` with linked BigQuery Log Analytics.
- **Binary Authorization:** Enforces attestor policies to ensure only verified, scanned images are run in Cloud Run.
