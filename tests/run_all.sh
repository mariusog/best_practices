#!/usr/bin/env bash
# Run all template integrity tests.
# Usage: bash tests/run_all.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0
ERRORS=""

run_test() {
    local test_file="$1"
    local name
    name="$(basename "$test_file" .sh)"
    if bash "$test_file" "$ROOT" 2>/dev/null; then
        PASS=$((PASS + 1))
        echo "  PASS  $name"
    else
        FAIL=$((FAIL + 1))
        ERRORS="$ERRORS\n  FAIL  $name"
        echo "  FAIL  $name"
    fi
}

echo "Running template integrity tests..."
echo ""

for dir in "$ROOT"/tests/*/; do
    [ -d "$dir" ] || continue
    section="$(basename "$dir")"
    echo "[$section]"
    for test_file in "$dir"/*.sh; do
        [ -f "$test_file" ] || continue
        run_test "$test_file"
    done
    echo ""
done

echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
    echo -e "\nFailures:$ERRORS"
    exit 1
fi
