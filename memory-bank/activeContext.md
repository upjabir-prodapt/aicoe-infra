# Active Context

## Current Focus
The active focus is preparing and applying **Stage 5 (Network PSC)** in Frankfurt (`europe-west3`) to connect the VPC to Apigee and provision Google API PSC endpoints.

## Recent Changes & Actions
- **Completed Frankfurt Single-Region Alignment (KMS, VPC, and Certs):**
  - **Destroyed Stage 3 Belgium VPC:** Successfully removed 18 resources in `europe-west1`, detaching service projects cleanly.
  - **Rename + State Forget on Stage 2 KMS:** Excluded old `europe-west1` KMS modules from state using `terraform state rm` and renamed all key rings to append `-ew3` (e.g. `aihub-ew3`, `logs-ew3`, `st-ew3`, `ingress-ew3`) in the code.
  - **Re-applied Stage 2 and 3 in `europe-west3`:** Recreated all KMS keyrings, Firestore, Log Analytics bucket, BigQuery dataset, GCS bucket, and regional SSL certificates (`cert-aihub` and `cert-backend`) in Frankfurt (`europe-west3`).
  - **Rebuilt Subnets:** Provisioned all 5 subnets with pristine `_ew3` naming hygiene inside Frankfurt.
  - **Updated Handoffs:** Updated centralized handoff files for Stage 2 and Stage 3 in `vars-handoff/`.
- **Stage 4 Completed successfully:** Deployed the Apigee Organization in the German control plane (`DE`), split the KMS keyring modules, and provisioned the physical Apigee Instance and runtime environments in Frankfurt `europe-west3`. Exported `4-apigee.auto.tfvars.json` to `vars-handoff/`.
- **Option B Centralization Implemented:** Created `terraform/vars-handoff/` to centralize all `.auto.tfvars.json` files. Updated `terraform/ci/job-templates.yml` to support this folder structure in the CI/CD pipeline.

## Next Steps
1. Coordinate Cloud Run app deployments to unblock **Stages 6a and 6b** (bff workload NEG, translation backend, sales-agent backend).
2. Apply **Stage 6a (AI Hub UI)** and **Stage 6b (ST)** backends.
3. Apply **Stage 6c (Ingress)** to bind backends to the Ingress Load Balancer.
4. Modify **Stage 7** to include the Model Armor templates and regional endpoint provider configuration.
5. Apply **Stage 7 (Apigee Runtime)**.
6. Verify Apigee env group TLS certificate status post-apply (for `aihub-api` / `llm` hostnames) and track keystore configuration if needed in Stage 7.

## Active Decisions & Considerations
- **No going back:** Staged deployments require strict order. Changes to Stage 2 are made now because Stage 3 is not yet fully complete.
- **Model Armor Region:** Must use `europe-west3.rep.googleapis.com` via regional PSC. Global endpoint workaround in Stage 2 has been retired.
- **Colt DNS Routable IP Exception:** Apigee PSC endpoint IP shifted from `192.168.6.146` to `10.110.73.10` (routable subnetwork) to satisfy corporate DNS registration requirements.
- **Network API Enablement:** Enabled `aiplatform.googleapis.com` in `gclt-aicoe-dev-network` to allow service-class and regional endpoint resolution.
- **Vector Search SCP Parked:** commented out automatic Vector Search PSC connection policy due to backend serviceClass restriction in `europe-west3` currently.
- **Folder Owner:** Folder owners on `846301442455` hold `roles/owner` which covers `roles/compute.xpnAdmin` needed for Shared VPC host/service project attachment.
