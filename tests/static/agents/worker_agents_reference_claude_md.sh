#!/usr/bin/env bash
# Worker agents should reference CLAUDE.md for shared standards instead of duplicating.
ROOT="${1:-.}"
status=0
for agent in core-agent feature-agent qa-agent; do
    f="$ROOT/.claude/agents/$agent.md"
    if ! grep -q "CLAUDE.md" "$f"; then
        echo "$agent.md: does not reference CLAUDE.md for shared standards"
        status=1
    fi
done
exit $status
