#!/usr/bin/env bash
# Shared helpers for the containerised linters. Source this file; do not execute it.

set -uo pipefail

# Git Bash rewrites arguments that look like Unix paths, which would mangle the
# container-side paths (/workspace, /config, /tmp) before Podman ever sees them.
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL='*'

# Names the messages after the calling script, for example "markdownlint".
command_name="$(basename -- "$0" .sh)"

fail() {
  echo "$command_name: $1" >&2
  exit "$2"
}

# Podman needs a Windows-style path for the host side of a volume mount.
to_host_path() {
  if command -v cygpath >/dev/null 2>&1; then
    cygpath --mixed "$1"
  else
    printf '%s' "$1"
  fi
}

container_platform_recover() {
  echo "$command_name: Starting the Podman machine..." >&2
  podman machine start >/dev/null ||
    fail "The Podman engine could not be started." 125
}

# Usage: container_run [--mount HOST_PATH TARGET] [--writable] [--interactive] IMAGE [ARG...]
container_run() {
  command -v podman >/dev/null 2>&1 ||
    fail "Podman is not installed or is not available on PATH." 127

  local mounts=()
  local mount_mode="ro"
  local stdin_options=()

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --mount)
        mounts+=(--volume "$(to_host_path "$2"):$3")
        shift 3
        ;;
      --writable)
        mount_mode="rw"
        shift
        ;;
      --interactive)
        stdin_options=(--interactive)
        shift
        ;;
      --)
        shift
        break
        ;;
      *)
        break
        ;;
    esac
  done

  local image="$1"
  shift

  local host_workspace
  host_workspace="$(to_host_path "$(pwd)")"

  local podman_args=(run --rm --pull=missing
    --network none
    --read-only
    --cap-drop all
    --security-opt no-new-privileges
    --pids-limit 128
    --tmpfs "/tmp:rw,noexec,nosuid,nodev,size=64m"
    "${stdin_options[@]}"
    "${mounts[@]}"
    --volume "$host_workspace:/workspace:$mount_mode"
    --workdir /workspace
    "$image" "$@")

  local error_file
  error_file="$(mktemp "${TMPDIR:-/tmp}/cli-tools.XXXXXX")" ||
    fail "Could not create a temporary error file." 74

  local attempt=0
  local run_error
  while true; do
    if podman "${podman_args[@]}" 2>"$error_file"; then
      rm -f -- "$error_file"
      return 0
    else
      run_error=$?
    fi

    if [ "$attempt" -eq 1 ] ||
      ! grep -Eiq 'cannot connect to Podman|unable to connect to Podman|connection refused' "$error_file"; then
      cat -- "$error_file" >&2
      rm -f -- "$error_file"
      return "$run_error"
    fi

    if ! container_platform_recover; then
      cat -- "$error_file" >&2
      rm -f -- "$error_file"
      return 125
    fi
    attempt=1
  done
}
