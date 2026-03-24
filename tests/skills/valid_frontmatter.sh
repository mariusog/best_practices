#!/usr/bin/env bash
# Every SKILL.md must have YAML frontmatter with name and description fields.
ROOT="${1:-.}"
status=0
for skill_md in "$ROOT"/.claude/skills/*/SKILL.md; do
    [ -f "$skill_md" ] || continue
    name="$(basename "$(dirname "$skill_md")")"

    # Check frontmatter delimiters exist
    if ! head -1 "$skill_md" | grep -q "^---"; then
        echo "$name: missing opening --- frontmatter delimiter"
        status=1
        continue
    fi

    # Extract frontmatter (between first and second ---)
    fm=$(sed -n '2,/^---$/p' "$skill_md" | head -n -1)

    if ! echo "$fm" | grep -q "^name:"; then
        echo "$name: frontmatter missing 'name' field"
        status=1
    fi
    if ! echo "$fm" | grep -q "^description:"; then
        echo "$name: frontmatter missing 'description' field"
        status=1
    fi
done
exit $status
