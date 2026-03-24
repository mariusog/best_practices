#!/usr/bin/env bash
# Every agent referenced in CLAUDE.md's File Ownership table must have a .md on disk.
ROOT="${1:-.}"
status=0

agents=$(grep -oP '(lead|core|feature|qa|researcher)-agent' "$ROOT/CLAUDE.md" | sort -u)

for agent in $agents; do
    if [ ! -f "$ROOT/.claude/agents/$agent.md" ]; then
        echo "CLAUDE.md references '$agent' but .claude/agents/$agent.md not found"
        status=1
    fi
done
exit $status
