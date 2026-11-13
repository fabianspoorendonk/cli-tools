#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname -- "${BASH_SOURCE[0]}")/.."

# Smoke checks: a quick real-world validation that each wrapper starts and resolves
# the expected upstream binary version or output.

echo "Checking jq..."
./bin/jq --version | grep -Eq '^jq-[0-9]+\.[0-9]+\.[0-9]+$'
./bin/jq '.name' tests/fixtures/sample.json | grep -Fx '"demo"'

echo "Checking yq..."
./bin/yq -V | grep -Eq 'version v[0-9]+\.[0-9]+\.[0-9]+'
./bin/yq '.service.name' tests/fixtures/sample.yaml | grep -Fx 'demo'

echo "Checking actionlint..."
./bin/actionlint -version | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'

echo "Checking hadolint..."
./bin/hadolint --version | grep -Eq '^Haskell Dockerfile Linter [0-9]+\.[0-9]+\.[0-9]+$'
./bin/hadolint tests/fixtures/Dockerfile
if hadolint_output="$(printf 'FROM alpine:latest\n' | ./bin/hadolint - 2>&1)"; then
	echo "Expected Hadolint to reject an unpinned Dockerfile." >&2
	exit 1
fi
printf '%s\n' "$hadolint_output" | grep -q 'DL3007'

echo "Checking shellcheck..."
./bin/shellcheck --version | grep -Eq '^version: [0-9]+\.[0-9]+\.[0-9]+$'

echo "Checking markdownlint..."
./bin/markdownlint README.md >/dev/null

echo "Smoke checks passed."
