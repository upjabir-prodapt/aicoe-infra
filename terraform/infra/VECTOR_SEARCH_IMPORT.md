# Vector Search — Terraform import runbook (sandox)

Console-deployed resources must be imported before the first `apply` on this branch.
Apply order: **static → network → infra**.

## 1. Static layer

```bash
cd terraform/static
make plan apply ENVNAME=sandox
```

## 2. Network layer

Remove the forwarding rule from network state (resource remains in GCP; infra adopts it):

```bash
cd terraform/network
terraform init -backend-config 'bucket=aicoesandox-bucket-tf-state' -backend-config 'prefix=tfstate-network'
terraform state rm google_compute_forwarding_rule.aicoe_psc_vector_index_fr
make plan apply ENVNAME=sandox
```

## 3. Infra layer — import console resources

```bash
cd terraform/infra
terraform init -backend-config 'bucket=aicoesandox-bucket-tf-state' -backend-config 'prefix=tfstate-infra'

terraform import -var-file=params/sandox/params.tfvars \
  google_vertex_ai_index.aicoe_vector_search_index \
  projects/aicoesandox/locations/europe-west1/indexes/2132951402815684608

terraform import -var-file=params/sandox/params.tfvars \
  google_vertex_ai_index_endpoint.aicoe_vector_index_endpoint \
  projects/aicoesandox/locations/europe-west1/indexEndpoints/4078260151235117056

terraform import -var-file=params/sandox/params.tfvars \
  google_vertex_ai_index_endpoint_deployed_index.aicoe_vector_deployed_index \
  'projects/aicoesandox/locations/europe-west1/indexEndpoints/4078260151235117056/deployedIndexes/aicoesandox_vector_index'

terraform import -var-file=params/sandox/params.tfvars \
  google_compute_forwarding_rule.aicoe_psc_vector_index_fr \
  projects/aicoesandox/regions/europe-west1/forwardingRules/aicoesandox-psc-vector-index-fr

make plan apply ENVNAME=sandox
```

`terraform plan` should show **no creates** for index, endpoint, deployed index, or forwarding rule.

## 4. Manual secret update (not managed by Terraform)

Copy outputs into `sales-agent-service-env`:

```bash
# static outputs
terraform output -state=../static/... vector_search_bucket_name

# network outputs
terraform output vector_search_psc_ip

# infra outputs
terraform output vector_search_index_id
terraform output vector_search_index_endpoint_id
terraform output vector_search_deployed_index_id
```

Then redeploy Cloud Run with the new secret version.

## Service accounts (no dedicated vector SA)

| Identity | Email |
|----------|-------|
| App (Cloud Run) | `aicoesandox-app-sa@aicoesandox.iam.gserviceaccount.com` |
| Vertex AI agent | `service-297743845367@gcp-sa-aiplatform.iam.gserviceaccount.com` |
