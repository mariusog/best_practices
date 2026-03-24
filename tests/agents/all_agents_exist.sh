#!/usr/bin/env bash
# Verify all expected agent files exist.
ROOT="${1:-.}"
status=0
for agent in lead-agent core-agent feature-agent qa-agent researcher-agent; do
    if [ ! -f "$ROOT/.claude/agents/$agent.md" ]; then
        echo "Missing: .claude/agents/$agent.md"
        status=1
    fi
done
exit $status
