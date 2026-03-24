#!/usr/bin/env bash
# Test: QA agent understands its audit procedure and escalation powers.
# Fast test (~2 min) -- validates understanding, not execution.
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/test-helpers.sh"

echo "  [qa-agent] Understanding test"

PROMPT=$(cat "$DIR/prompts/qa-agent-understanding.txt")
run_claude "$PROMPT" 3 120

# Must describe the audit procedure
assert_contains "public method" "Checks public methods for coverage"
assert_contains "test" "References test files"
assert_contains "gap" "Identifies coverage gaps"

# Must know about escalation
assert_contains "CRITICAL" "Knows CRITICAL escalation tag"
assert_contains "security" "Mentions security as an escalation trigger"

# Must reference the correct plan file
assert_contains "TASKS-qa" "Reports to TASKS-qa.md"

report_results
