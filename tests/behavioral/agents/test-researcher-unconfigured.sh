#!/usr/bin/env bash
# Test: Researcher agent prompts for configuration when placeholders are present.
# Fast test (~2 min) -- validates first-run behavior.
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/test-helpers.sh"

echo "  [researcher-agent] Unconfigured prompt test"

PROMPT=$(cat "$DIR/prompts/researcher-agent-unconfigured.txt")
run_claude "$PROMPT" 3 120

# Must detect the unconfigured state and ask the user
assert_contains "configured" "Detects agent is not configured"
assert_contains "domain" "Asks about the project domain"
assert_contains "goal" "Asks about the project goal"
assert_contains "stack" "Asks about the tech stack"

# Must NOT proceed with research when unconfigured
assert_not_contains "recommendation" "Does not give research recommendations before configuration"

report_results
