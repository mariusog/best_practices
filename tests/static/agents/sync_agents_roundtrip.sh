#!/usr/bin/env bash
# bin/sync-agents: a fresh sync passes --check; drift and a shadowed role fail it.
ROOT="${1:-.}"
status=0
target="$(mktemp -d)"
trap 'rm -rf "$target"' EXIT

fail() { echo "sync-agents: $1"; status=1; }

"$ROOT/bin/sync-agents" "$target" --roles "lead-agent core-agent" > /dev/null || fail "sync failed"
"$ROOT/bin/sync-agents" --check "$target" > /dev/null || fail "check failed on a fresh sync"

echo "project-only agent" > "$target/.claude/agents/project-only.md"
"$ROOT/bin/sync-agents" --check "$target" > /dev/null || fail "check rejected a project-only agent"

echo "edit" >> "$target/.claude/agents/core-agent.md"
"$ROOT/bin/sync-agents" --check "$target" > /dev/null && fail "check passed a hand-edited role"
"$ROOT/bin/sync-agents" "$target" > /dev/null

cp "$target/.claude/agents/lead-agent.md" "$target/.claude/agents/qa-agent.md"
"$ROOT/bin/sync-agents" --check "$target" > /dev/null && fail "check passed a project agent reusing a shared role name"

exit $status
