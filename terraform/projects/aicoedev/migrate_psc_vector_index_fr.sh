#!/usr/bin/env bash
# One-time state migration: move the PSC forwarding rule for vector search
# from the NETWORK layer's state to the INFRA layer's state.
#
# Why: the .tf code for both layers is already correct (network no longer
# declares this resource, infra's module.vector_search now creates it).
# But `moved` blocks only work within a single state/root module, so this
# one resource has to be relocated manually before `terraform plan` will
# show a clean diff on either layer.
#
# Run this from the directory that contains both the `network` and `infra`
# layer folders (e.g. terraform/projects/aicoedev), or adjust the -chdir
# paths below to match your layout.

set -euo pipefail

NETWORK_DIR="network"
INFRA_DIR="infra"
RESOURCE_FROM="google_compute_forwarding_rule.aicoe_psc_vector_index_fr"
RESOURCE_TO="module.vector_search.google_compute_forwarding_rule.psc_vector_index_fr"

TS=$(date +%Y%m%d%H%M%S)
NETWORK_STATE="/tmp/aicoedev-network-${TS}.tfstate"
INFRA_STATE="/tmp/aicoedev-infra-${TS}.tfstate"

echo "==> Pulling current state for network and infra..."
terraform -chdir="${NETWORK_DIR}" state pull > "${NETWORK_STATE}"
terraform -chdir="${INFRA_DIR}"   state pull > "${INFRA_STATE}"

echo "==> Backups written to:"
echo "    ${NETWORK_STATE}"
echo "    ${INFRA_STATE}"
echo "    (keep these until you've confirmed both layers plan clean)"

echo "==> Confirming the resource exists in network's state..."
if ! terraform -chdir="${NETWORK_DIR}" state list | grep -qx "${RESOURCE_FROM}"; then
  echo "ERROR: ${RESOURCE_FROM} not found in network state." >&2
  echo "Run 'terraform -chdir=${NETWORK_DIR} state list | grep psc_vector' to check the actual address." >&2
  exit 1
fi

echo "==> Moving ${RESOURCE_FROM}"
echo "        -> ${RESOURCE_TO}"
terraform state mv \
  -state="${NETWORK_STATE}" \
  -state-out="${INFRA_STATE}" \
  "${RESOURCE_FROM}" \
  "${RESOURCE_TO}"

echo "==> Pushing updated state back to both backends..."
terraform -chdir="${NETWORK_DIR}" state push "${NETWORK_STATE}"
terraform -chdir="${INFRA_DIR}"   state push "${INFRA_STATE}"

echo "==> Done. Now run 'terraform plan' in both ${NETWORK_DIR} and ${INFRA_DIR}"
echo "    to confirm a clean (0 to add/change/destroy) diff."