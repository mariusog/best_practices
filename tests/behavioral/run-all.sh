#!/usr/bin/env bash
# Run all behavioral tests (requires Claude CLI installed).
# These tests invoke Claude to verify agents and skills are understood correctly.
# Fast tests: ~2 min each. Run from the repo root.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v claude &>/dev/null; then
    echo "Skipping behavioral tests -- claude CLI not installed"
    exit 0
fi

echo "Running behavioral tests (requires Claude CLI)..."
echo ""

PASS=0
FAIL=0

for test_file in "$DIR"/agents/test-*.sh "$DIR"/skills/test-*.sh; do
    [ -f "$test_file" ] || continue
    name="$(basename "$test_file" .sh)"
    echo "  [$name]"
    if bash "$test_file"; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
    fi
    echo ""
done

echo "Behavioral results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
