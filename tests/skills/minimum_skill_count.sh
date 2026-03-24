#!/usr/bin/env bash
# Verify we have at least 25 skills (catches accidental deletions).
ROOT="${1:-.}"
count=$(find "$ROOT/.claude/skills" -maxdepth 1 -mindepth 1 -type d | wc -l)
if [ "$count" -lt 25 ]; then
    echo "Expected at least 25 skills, found $count"
    exit 1
fi
exit 0
