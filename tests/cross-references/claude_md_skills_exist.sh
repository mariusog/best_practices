#!/usr/bin/env bash
# Every skill referenced in CLAUDE.md's decision tree must have a SKILL.md on disk.
ROOT="${1:-.}"
status=0

# Extract skill names from "-> skill-name" patterns in the decision tree
skills=$(grep -oP '(?<=->\s)\S+' "$ROOT/CLAUDE.md" | sort -u)

for skill in $skills; do
    # Skip non-skill references (e.g., lines that aren't skill names)
    case "$skill" in
        */*|*"("*|*")"*) continue ;;
    esac
    if [ ! -f "$ROOT/.claude/skills/$skill/SKILL.md" ]; then
        echo "CLAUDE.md references skill '$skill' but .claude/skills/$skill/SKILL.md not found"
        status=1
    fi
done
exit $status
