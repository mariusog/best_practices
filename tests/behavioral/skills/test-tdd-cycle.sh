#!/usr/bin/env bash
# Test: TDD cycle skill is understood correctly.
# Fast test (~2 min) -- validates understanding, not execution.
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/test-helpers.sh"

echo "  [tdd-cycle] Understanding test"

PROMPT=$(cat "$DIR/prompts/skill-tdd-understanding.txt")
run_claude "$PROMPT" 3 120

# Must describe the three phases
assert_contains "red" "Mentions Red phase (failing test)"
assert_contains "green" "Mentions Green phase (make it pass)"
assert_contains "refactor" "Mentions Refactor phase"

# Must explain the correct order
assert_order "red" "green" "Red phase comes before Green"
assert_order "green" "refactor" "Green phase comes before Refactor"

# Must address the edge case of tests passing immediately
assert_contains "pass" "Addresses what happens when test passes immediately"

report_results
