#!/usr/bin/env bash
# Install Terraform into ${CI_PROJECT_DIR}/bin using HTTP(S)_PROXY when set.
set -euo pipefail

ROOT_DIR="${CI_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
VERSION_FILE="${ROOT_DIR}/.terraform-version"
BIN_DIR="${ROOT_DIR}/bin"

if [[ -f "${VERSION_FILE}" ]]; then
  TF_VERSION="$(tr -d '[:space:]' < "${VERSION_FILE}")"
else
  TF_VERSION="${TF_VERSION:-1.15.7}"
fi

export http_proxy="${HTTP_PROXY:-${http_proxy:-}}"
export https_proxy="${HTTPS_PROXY:-${https_proxy:-${http_proxy}}}"
export HTTP_PROXY="${http_proxy}"
export HTTPS_PROXY="${https_proxy}"
export no_proxy="${NO_PROXY:-${no_proxy:-}}"
export NO_PROXY="${no_proxy}"

mkdir -p "${BIN_DIR}"

if [[ -x "${BIN_DIR}/terraform" ]]; then
  CURRENT="$("${BIN_DIR}/terraform" version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
  if [[ "${CURRENT}" == "${TF_VERSION}" ]]; then
    export PATH="${BIN_DIR}:${PATH}"
    echo "Terraform ${TF_VERSION} already installed in ${BIN_DIR}"
    exit 0
  fi
fi

ZIP="/tmp/terraform_${TF_VERSION}_linux_amd64.zip"
URL="https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"

echo "Installing Terraform ${TF_VERSION} into ${BIN_DIR}"
if [[ -n "${https_proxy}" ]]; then
  echo "Using proxy: ${https_proxy}"
fi

download() {
  if command -v curl >/dev/null 2>&1; then
    CURL_OPTS=(-fsSL --connect-timeout 30 --max-time 300)
    if [[ -n "${https_proxy}" ]]; then
      curl "${CURL_OPTS[@]}" -x "${https_proxy}" "${URL}" -o "${ZIP}"
    else
      curl "${CURL_OPTS[@]}" "${URL}" -o "${ZIP}"
    fi
    return 0
  fi

  if command -v wget >/dev/null 2>&1; then
    if [[ -n "${https_proxy}" ]]; then
      wget -q \
        -e use_proxy=yes \
        -e "https_proxy=${https_proxy}" \
        -e "http_proxy=${http_proxy}" \
        -O "${ZIP}" \
        "${URL}"
    else
      wget -q -O "${ZIP}" "${URL}"
    fi
    return 0
  fi

  echo "ERROR: curl or wget is required to download Terraform."
  exit 1
}

download

if command -v unzip >/dev/null 2>&1; then
  unzip -o -q "${ZIP}" -d "${BIN_DIR}"
elif command -v python3 >/dev/null 2>&1; then
  python3 -m zipfile -e "${ZIP}" "${BIN_DIR}"
else
  echo "ERROR: unzip or python3 is required to extract Terraform."
  exit 1
fi

chmod +x "${BIN_DIR}/terraform"
rm -f "${ZIP}"

export PATH="${BIN_DIR}:${PATH}"

INSTALLED="$("${BIN_DIR}/terraform" version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
if [[ "${INSTALLED}" != "${TF_VERSION}" ]]; then
  echo "ERROR: expected Terraform ${TF_VERSION}, got ${INSTALLED}"
  exit 1
fi

echo "Terraform ${INSTALLED} ready at ${BIN_DIR}/terraform"
