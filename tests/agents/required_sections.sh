#!/usr/bin/env bash
# Verify agent files have required sections.
ROOT="${1:-.}"
status=0

check_section() {
    local file="$1" section="$2"
    if ! grep -q "^## $section" "$file"; then
        echo "$(basename "$file"): missing ## $section"
        status=1
    fi
}

# All agents must have Role
for f in "$ROOT"/.claude/agents/*.md; do
    check_section "$f" "Role"
done

# Worker agents must have Task Workflow and Git
for agent in core-agent feature-agent qa-agent; do
    f="$ROOT/.claude/agents/$agent.md"
    check_section "$f" "Task Workflow"
    check_section "$f" "Git"
done

# Lead and researcher must have First Run Check
check_section "$ROOT/.claude/agents/lead-agent.md" "First Run Check"
check_section "$ROOT/.claude/agents/researcher-agent.md" "First Run Check"

# Lead must have Strategic Planning
check_section "$ROOT/.claude/agents/lead-agent.md" "Strategic Planning"

exit $status
