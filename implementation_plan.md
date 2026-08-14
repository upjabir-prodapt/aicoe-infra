# Implementation Plan

[Overview]
Continue the AI CoE Dev Platform deployment by executing Stage 3 (Network) and proceeding to subsequent stages, ensuring all pre-flight checks are met and known blockers are addressed. We will also incorporate architectural updates to support Model Armor's regional PSC endpoint.

The AI CoE Dev Platform migration paused after successfully completing Stage 2 (Foundations). The goal now is to apply the terraform plan for Stage 3 (Network) which has been generated and validated, followed by Stage 4 (Apigee), Stage 5 (Network PSC), and the remaining workloads (Stage 6) and Apigee runtime (Stage 7). Based on recent findings, Stage 5 will be augmented to include a dedicated regional PSC endpoint and specific private DNS zone for Model Armor, bypassing the global Google APIs PSC bundle.

[Types]
No changes to type systems are required for this infrastructure deployment.

The platform uses standard Terraform HCL typed variables and data structures defined in the existing modules.

[Files]
Updates to Terraform code to support the Model Armor PSC endpoint, alongside generating subsequent tfvars artifacts.

Detailed breakdown:
- Existing files to be modified: 
  - `terraform/5-network-psc/main.tf`: Add the regional PSC endpoint, IP address, managed DNS zone, and A record for Model Armor.
- Configuration file updates: We will generate and export outputs (like `3-network.auto.tfvars.json`) to be used by downstream stages.

[Functions]
No application function modifications are required.

Detailed breakdown:
- The execution relies entirely on Terraform core commands (`init`, `plan`, `apply`, `output`).

[Classes]
No class modifications are required.

Detailed breakdown:
- This is a purely infrastructure-as-code deployment task. The main structural change is the introduction of a `google_network_connectivity_regional_endpoint` resource.

[Dependencies]
Dependency handoffs between Terraform stages.

Detailed breakdown:
- Stage 3 outputs must be passed to Stage 4 and Stage 5.
- The Apigee instance in Stage 4 must finish before Stage 5 creates the PSC endpoints.

[Implementation Order]
Execute Terraform stages sequentially, handling outputs and potential IAM blockers.

1. Apply the validated Stage 3 (Network) Terraform plan (`terraform apply tfplan`).
2. Handle the known risk: if the Shared VPC attachment fails with a 403 error, request or grant `roles/compute.xpnAdmin` on the AI COE folder (`846301442455`).
3. Export Stage 3 outputs to a JSON artifact for downstream stages.
4. Prepare and execute Stage 4 (Apigee), initializing and applying the Terraform configuration.
5. Export Stage 4 outputs to a JSON artifact.
6. Modify `terraform/5-network-psc/main.tf` to implement the Model Armor regional endpoint architecture (allocate IP, create `google_network_connectivity_regional_endpoint`, private zone, and A record).
7. Prepare and execute Stage 5 (Network PSC) to create PSC endpoints connecting Apigee, Google APIs, and the new Model Armor endpoint.
8. Update `docs/BUILD-LOG.md` to reflect completion of Stages 3, 4, and 5, logging any additional blockers encountered.

