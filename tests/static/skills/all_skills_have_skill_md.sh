#!/usr/bin/env bash
# Every skill directory must contain a SKILL.md file.
ROOT="${1:-.}"
status=0
for dir in "$ROOT"/.claude/skills/*/; do
    [ -d "$dir" ] || continue
    if [ ! -f "$dir/SKILL.md" ]; then
        echo "Missing SKILL.md in $(basename "$dir")"
        status=1
    fi
done
exit $status
