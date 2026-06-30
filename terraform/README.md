# AICOE Terraform Layout

## Structure

```
terraform/
├── modules/           # Shared reusable modules (flat layout)
└── projects/          # One folder per GCP project/workload
    └── <project>/
        ├── static/    # Optional layer
        ├── network/   # Optional layer
        └── infra/     # Optional layer
```

## Branches

| Branch | Environment | Projects |
|--------|-------------|----------|
| `main` / `sandbox-v1` | sandbox | aicoe-core, ai-research, pricing-agent, svcmgmtops, aicoeaiworkshop |
| `dev` | dev | aicoe-core, omfocuslane, vegadev |
| `prod` | prod | aicoe-core |

## State isolation

Each project layer uses its own GCS state prefix:

`{project_name}/tfstate-{static|network|infra}`

## Usage

```bash
cd terraform/projects/aicoe-core/static
make plan ENVNAME=sandox
make apply ENVNAME=sandox
```

For dev/prod on `aicoe-core`, copy or symlink the matching params file:

- `params.dev.tfvars` on `dev` branch
- `params.prod.tfvars` on `prod` branch

## CI/CD

- Root `azure-pipelines.yml` — aicoe-core (sandbox)
- `pipelines/azure-pipelines-*.yml` — per-project pipelines with path triggers
