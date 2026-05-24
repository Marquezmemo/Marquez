#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
WORKSPACE_WAIT_TIMEOUT="${WORKSPACE_WAIT_TIMEOUT:-120}"
WORKSPACE_WAIT_INTERVAL="${WORKSPACE_WAIT_INTERVAL:-2}"
LOG_PREFIX="${LOG_PREFIX:-workspace-check}"
deadline=$((SECONDS + WORKSPACE_WAIT_TIMEOUT))

is_writable_workspace() {
  local probe_file
  probe_file="${WORKSPACE_DIR}/.workspace-write-test"

  [ -d "${WORKSPACE_DIR}" ] || return 1
  mountpoint -q "${WORKSPACE_DIR}" || return 1
  touch "${probe_file}" 2>/dev/null || return 1
  rm -f "${probe_file}" 2>/dev/null || return 1
}

while ! is_writable_workspace; do
  if [ "${SECONDS}" -ge "${deadline}" ]; then
    echo "${LOG_PREFIX}: ${WORKSPACE_DIR} is not a mounted writable volume after ${WORKSPACE_WAIT_TIMEOUT}s" >&2
    echo "${LOG_PREFIX}: refusing to initialize stack without a ready persistent workspace" >&2
    exit 1
  fi

  echo "${LOG_PREFIX}: waiting for mounted writable ${WORKSPACE_DIR}..." >&2
  sleep "${WORKSPACE_WAIT_INTERVAL}"
done

mkdir -p "${WORKSPACE_DIR}/logs"
echo "${LOG_PREFIX}: ${WORKSPACE_DIR} is mounted and writable"
