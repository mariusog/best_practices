#!/usr/bin/env bash
# Run all tests: static validation + behavioral (if Claude CLI is available).
#
# Usage:
#   bash tests/run_all.sh           # Run static + behavioral
#   bash tests/run_all.sh --static  # Run static only (no Claude CLI needed)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATIC_ONLY=false
[ "${1:-}" = "--static" ] && STATIC_ONLY=true

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

# --- Static tests (no dependencies) ---
echo "Static tests"
echo "============"
echo ""

for dir in "$ROOT"/tests/static/*/; do
    [ -d "$dir" ] || continue
    section="$(basename "$dir")"
    echo "[$section]"
    for test_file in "$dir"/*.sh; do
        [ -f "$test_file" ] || continue
        run_test "$test_file"
    done
    echo ""
done

# --- Behavioral tests (require Claude CLI) ---
if [ "$STATIC_ONLY" = false ]; then
    if command -v claude &>/dev/null; then
        echo "Behavioral tests"
        echo "================"
        echo ""
        bash "$ROOT/tests/behavioral/run-all.sh" && true
        # Behavioral tests report their own results
    else
        echo "Skipping behavioral tests -- claude CLI not installed"
        echo "Run 'npm install -g @anthropic-ai/claude-code' to enable"
        echo ""
    fi
fi

echo "Static results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
    echo -e "\nFailures:$ERRORS"
    exit 1
fi
