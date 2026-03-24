#!/usr/bin/env bash
# TASKS.md template must have the required sections.
ROOT="${1:-.}"
status=0
tasks="$ROOT/templates/TASKS.md"
for section in "## Open" "## In Progress" "## Done"; do
    if ! grep -q "$section" "$tasks"; then
        echo "TASKS.md missing section: $section"
        status=1
    fi
done
exit $status
