#!/usr/bin/env bash
# Install Terraform into ${CI_PROJECT_DIR}/bin using HTTP(S)_PROXY when set.
set -euo pipefail

ROOT_DIR="${CI_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
VERSION_FILE="${ROOT_DIR}/.terraform-version"
BIN_DIR="${ROOT_DIR}/bin"
CACHE_DIR="${ROOT_DIR}/.cache/terraform"

if [[ -f "${VERSION_FILE}" ]]; then
  TF_VERSION="$(tr -d '[:space:]' < "${VERSION_FILE}")"
else
  TF_VERSION="${TF_VERSION:-1.15.7}"
fi

ARCHIVE="terraform_${TF_VERSION}_linux_amd64.zip"
URL="https://releases.hashicorp.com/terraform/${TF_VERSION}/${ARCHIVE}"
CHECKSUMS_URL="https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_SHA256SUMS"
ZIP="${CACHE_DIR}/${ARCHIVE}"

export http_proxy="${HTTP_PROXY:-${http_proxy:-}}"
export https_proxy="${HTTPS_PROXY:-${https_proxy:-${http_proxy}}}"
export HTTP_PROXY="${http_proxy}"
export HTTPS_PROXY="${https_proxy}"
export no_proxy="${NO_PROXY:-${no_proxy:-}}"
export NO_PROXY="${no_proxy}"

mkdir -p "${BIN_DIR}" "${CACHE_DIR}"

terraform_version() {
  "${BIN_DIR}/terraform" version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1
}

if [[ -x "${BIN_DIR}/terraform" ]]; then
  CURRENT="$(terraform_version || true)"
  if [[ -n "${CURRENT}" && "${CURRENT}" == "${TF_VERSION}" ]]; then
    export PATH="${BIN_DIR}:${PATH}"
    echo "Terraform ${TF_VERSION} already installed in ${BIN_DIR}"
    exit 0
  fi
  echo "Removing stale or corrupt Terraform binary (found: ${CURRENT:-invalid})"
  rm -f "${BIN_DIR}/terraform"
fi

echo "Installing Terraform ${TF_VERSION} into ${BIN_DIR}"
if [[ -n "${https_proxy}" ]]; then
  echo "Using proxy: ${https_proxy}"
fi

CURL_RETRY_OPTS=(--retry 3 --retry-delay 5 --connect-timeout 30 --max-time 300)
if curl --help 2>&1 | grep -q -- '--retry-all-errors'; then
  CURL_RETRY_OPTS+=(--retry-all-errors)
fi

curl_download() {
  local url="$1"
  local dest="$2"
  if [[ -n "${https_proxy}" ]]; then
    curl -fsSL "${CURL_RETRY_OPTS[@]}" -x "${https_proxy}" "${url}" -o "${dest}"
  else
    curl -fsSL "${CURL_RETRY_OPTS[@]}" "${url}" -o "${dest}"
  fi
}

validate_zip() {
  local zip="$1"
  local min_bytes=10000000

  if [[ ! -s "${zip}" ]]; then
    echo "ERROR: download is empty: ${zip}"
    return 1
  fi

  local size
  size="$(wc -c < "${zip}" | tr -d '[:space:]')"
  if [[ "${size}" -lt "${min_bytes}" ]]; then
    echo "ERROR: download too small (${size} bytes); proxy may have returned an HTML error page"
    head -c 200 "${zip}" || true
    echo ""
    return 1
  fi

  if ! head -c 2 "${zip}" | grep -q 'PK'; then
    echo "ERROR: download is not a zip file (missing PK header)"
    head -c 200 "${zip}" || true
    echo ""
    return 1
  fi

  if command -v unzip >/dev/null 2>&1; then
    unzip -tq "${zip}" >/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    python3 -m zipfile -t "${zip}" >/dev/null
  fi
}

verify_checksum() {
  local zip="$1"
  if ! command -v sha256sum >/dev/null 2>&1; then
    echo "WARN: sha256sum not available; skipping checksum verification"
    return 0
  fi

  local sums="${CACHE_DIR}/terraform_${TF_VERSION}_SHA256SUMS"
  curl_download "${CHECKSUMS_URL}" "${sums}"

  local expected actual
  expected="$(grep " ${ARCHIVE}$" "${sums}" | awk '{print $1}')"
  if [[ -z "${expected}" ]]; then
    echo "WARN: no SHA256 entry for ${ARCHIVE}; skipping checksum verification"
    return 0
  fi

  actual="$(sha256sum "${zip}" | awk '{print $1}')"
  if [[ "${actual}" != "${expected}" ]]; then
    echo "ERROR: SHA256 mismatch for ${ARCHIVE}"
    echo "  expected: ${expected}"
    echo "  actual:   ${actual}"
    return 1
  fi
  echo "SHA256 verified for ${ARCHIVE}"
}

download_archive() {
  rm -f "${ZIP}"
  curl_download "${URL}" "${ZIP}"
  validate_zip "${ZIP}"
  verify_checksum "${ZIP}"
}

if [[ -f "${ZIP}" ]]; then
  if ! validate_zip "${ZIP}"; then
    rm -f "${ZIP}"
  fi
fi

if [[ ! -f "${ZIP}" ]]; then
  attempt=1
  max_attempts=3
  while [[ "${attempt}" -le "${max_attempts}" ]]; do
    echo "Downloading ${ARCHIVE} (attempt ${attempt}/${max_attempts})"
    if download_archive; then
      break
    fi
    rm -f "${ZIP}"
    attempt=$((attempt + 1))
    if [[ "${attempt}" -gt "${max_attempts}" ]]; then
      echo "ERROR: failed to download a valid Terraform archive from ${URL}"
      exit 1
    fi
    sleep 5
  done
fi

if command -v unzip >/dev/null 2>&1; then
  unzip -o -q "${ZIP}" -d "${BIN_DIR}"
elif command -v python3 >/dev/null 2>&1; then
  python3 -m zipfile -e "${ZIP}" "${BIN_DIR}"
else
  echo "ERROR: unzip or python3 is required to extract Terraform."
  exit 1
fi

chmod +x "${BIN_DIR}/terraform"

export PATH="${BIN_DIR}:${PATH}"

INSTALLED="$(terraform_version || true)"
if [[ "${INSTALLED}" != "${TF_VERSION}" ]]; then
  echo "ERROR: expected Terraform ${TF_VERSION}, got ${INSTALLED:-<none>}"
  rm -f "${BIN_DIR}/terraform"
  exit 1
fi

echo "Terraform ${INSTALLED} ready at ${BIN_DIR}/terraform"
