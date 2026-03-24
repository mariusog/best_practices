#!/usr/bin/env bash
# Test: Open source audit skill is understood correctly.
# Fast test (~2 min) -- validates understanding, not execution.
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/test-helpers.sh"

echo "  [open-source-audit] Understanding test"

PROMPT=$(cat "$DIR/prompts/skill-open-source-audit-understanding.txt")
run_claude "$PROMPT" 3 120

# Must cover the key audit categories
assert_contains "token" "Checks for API tokens/secrets"
assert_contains "email" "Checks for personal emails"
assert_contains "cloud" "Checks for cloud provider IDs"
assert_contains "URL" "Checks for internal URLs"
assert_contains "gitignore" "Includes gitignore verification"

# Must mention grep patterns
assert_contains "grep" "Describes grep-based scanning"

report_results
