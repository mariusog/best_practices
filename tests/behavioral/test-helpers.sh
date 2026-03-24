#!/usr/bin/env bash
# Shared test helpers for behavioral tests.
# Sources by individual test files.
set -euo pipefail

PASS_COUNT=0
FAIL_COUNT=0
TEST_NAME=""

# Run a prompt against Claude and capture output.
# Usage: run_claude "prompt text" [max_turns] [timeout]
run_claude() {
    local prompt="$1"
    local max_turns="${2:-3}"
    local timeout_s="${3:-120}"

    OUTPUT=$(timeout "$timeout_s" claude -p "$prompt" \
        --output-format text \
        --max-turns "$max_turns" \
        2>&1) || true
}

# Assert that Claude's output contains a pattern.
assert_contains() {
    local pattern="$1"
    local description="${2:-output contains '$pattern'}"
    if echo "$OUTPUT" | grep -qi "$pattern"; then
        PASS_COUNT=$((PASS_COUNT + 1))
        echo "    PASS  $description"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo "    FAIL  $description"
    fi
}

# Assert that Claude's output does NOT contain a pattern.
assert_not_contains() {
    local pattern="$1"
    local description="${2:-output does not contain '$pattern'}"
    if echo "$OUTPUT" | grep -qi "$pattern"; then
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo "    FAIL  $description"
    else
        PASS_COUNT=$((PASS_COUNT + 1))
        echo "    PASS  $description"
    fi
}

# Assert pattern A appears before pattern B in output.
assert_order() {
    local first="$1"
    local second="$2"
    local description="${3:-'$first' appears before '$second'}"
    local first_line second_line
    first_line=$(echo "$OUTPUT" | grep -ni "$first" | head -1 | cut -d: -f1)
    second_line=$(echo "$OUTPUT" | grep -ni "$second" | head -1 | cut -d: -f1)
    if [ -n "$first_line" ] && [ -n "$second_line" ] && [ "$first_line" -lt "$second_line" ]; then
        PASS_COUNT=$((PASS_COUNT + 1))
        echo "    PASS  $description"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo "    FAIL  $description"
    fi
}

# Print test results and exit with appropriate code.
report_results() {
    echo ""
    echo "  Results: $PASS_COUNT passed, $FAIL_COUNT failed"
    [ "$FAIL_COUNT" -eq 0 ]
}
