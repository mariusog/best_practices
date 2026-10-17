#!/usr/bin/env bash
# Every role has the frontmatter Claude Code needs to pick it: its name and a description.
ROOT="${1:-.}"
status=0
for f in "$ROOT"/.claude/agents/*.md; do
    role="$(basename "$f" .md)"
    front="$(awk 'NR == 1 && $0 != "---" { exit } NR > 1 && $0 == "---" { exit } NR > 1' "$f")"
    grep -qx "name: $role" <<< "$front" || { echo "$role: frontmatter missing name: $role"; status=1; }
    grep -q "^description: Use " <<< "$front" || { echo "$role: frontmatter missing a 'Use ...' description"; status=1; }
done
exit $status
