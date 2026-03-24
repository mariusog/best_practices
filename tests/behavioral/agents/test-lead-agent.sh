#!/usr/bin/env bash
# Test: Lead agent understands its workflow and coordination responsibilities.
# Fast test (~2 min) -- validates understanding, not execution.
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/test-helpers.sh"

echo "  [lead-agent] Understanding test"

PROMPT=$(cat "$DIR/prompts/lead-agent-understanding.txt")
run_claude "$PROMPT" 3 120

# Must understand the first-run configuration check
assert_contains "placeholder\|configured\|first run\|update.*owned" "Mentions first-run configuration check"

# Must describe the task workflow in correct order
assert_contains "TASKS.md" "References TASKS.md for task tracking"
assert_contains "worktree" "Describes spawning agents in worktrees"
assert_order "diagnose" "delegate" "Diagnose comes before delegate"
assert_order "delegate" "review" "Delegate comes before review"

# Must understand escalation handling
assert_contains "BLOCKED" "Knows about BLOCKED tag for escalations"

report_results
