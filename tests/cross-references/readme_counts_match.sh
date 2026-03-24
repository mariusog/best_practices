#!/usr/bin/env bash
# README skill and agent counts should match what's on disk.
ROOT="${1:-.}"
status=0

skill_count=$(find "$ROOT/.claude/skills" -maxdepth 1 -mindepth 1 -type d | wc -l)
if ! grep -q "$skill_count" "$ROOT/README.md"; then
    echo "README skill count doesn't mention actual count ($skill_count)"
    status=1
fi

agent_count=$(find "$ROOT/.claude/agents" -maxdepth 1 -name "*.md" | wc -l)
if ! grep -qi "five\|5 agents\|$agent_count agent" "$ROOT/README.md"; then
    echo "README agent count doesn't match actual count ($agent_count)"
    status=1
fi

exit $status
