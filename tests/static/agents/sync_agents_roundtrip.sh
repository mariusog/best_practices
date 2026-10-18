#!/usr/bin/env bash
# bin/sync-agents: a fresh sync passes --check; drift and a shadowed role fail it;
# a context file's frontmatter and body are composed into the role.
ROOT="${1:-.}"
status=0
target="$(mktemp -d)"
trap 'rm -rf "$target"' EXIT

fail() { echo "sync-agents: $1"; status=1; }

"$ROOT/bin/sync-agents" "$target" --roles "lead-agent core-agent coordinator" > /dev/null || fail "sync failed"
"$ROOT/bin/sync-agents" --check "$target" > /dev/null || fail "check failed on a fresh sync"

echo "project-only agent" > "$target/.claude/agents/project-only.md"
"$ROOT/bin/sync-agents" --check "$target" > /dev/null || fail "check rejected a project-only agent"

echo "edit" >> "$target/.claude/agents/core-agent.md"
"$ROOT/bin/sync-agents" --check "$target" > /dev/null && fail "check passed a hand-edited role"
"$ROOT/bin/sync-agents" "$target" > /dev/null

cp "$target/.claude/agents/lead-agent.md" "$target/.claude/agents/qa-agent.md"
"$ROOT/bin/sync-agents" --check "$target" > /dev/null && fail "check passed a project agent reusing a shared role name"

agents="$target/.claude/agents" context="$target/.claude/agent-context"
rm "$agents/qa-agent.md"
mkdir -p "$context"
printf -- '---\ndescription: Use for the example project\n---\n\n# coordinator: example context\n' > "$context/coordinator.md"
printf '# core-agent: example context\n\nOwns lib/\n' > "$context/core-agent.md"
"$ROOT/bin/sync-agents" "$target" > /dev/null || fail "sync failed with context files"
"$ROOT/bin/sync-agents" --check "$target" > /dev/null || fail "check failed on a fresh sync with context files"
front="$(awk 'NR > 1 && $0 == "---" { exit } NR > 1' "$agents/coordinator.md")"
[[ "$front" == *"description: Use for the example project"* ]] || fail "context description did not replace the role's"
[[ "$front" != *"<example>"* ]] || fail "the role's multi-line description survived the override"
[[ "$front" == *"name: coordinator"* && "$front" == *"model: haiku"* ]] || fail "keys the context doesn't set were lost"
tail -1 "$agents/core-agent.md" | grep -qx "Owns lib/" || fail "context body was not appended"
git -C "$ROOT" show HEAD:.claude/agents/lead-agent.md | cmp -s - "$agents/lead-agent.md" || fail "a role without a context file was not copied verbatim"

echo "Owns src/ too" >> "$context/core-agent.md"
"$ROOT/bin/sync-agents" --check "$target" > /dev/null && fail "check passed a context file edited without re-syncing"
"$ROOT/bin/sync-agents" "$target" > /dev/null

printf -- '---\nname: renamed\n---\n' > "$context/core-agent.md"
"$ROOT/bin/sync-agents" "$target" > /dev/null 2>&1 && fail "sync let a context file set name:"

# Tracking mode: no ref in UPSTREAM, roles gitignored, the session hook composes from main.
tracked="$(mktemp -d)" cache="$(mktemp -d)"
trap 'rm -rf "$target" "$tracked" "$cache"' EXIT
"$ROOT/bin/sync-agents" "$tracked" --roles "lead-agent core-agent" --track > /dev/null || fail "tracking sync failed"
grep -q '^ref:' "$tracked/.claude/agents/UPSTREAM" && fail "tracking sync wrote a ref: into UPSTREAM"
grep -qx "core-agent.md" "$tracked/.claude/agents/.gitignore" || fail "tracking sync did not gitignore its roles"
"$ROOT/bin/sync-agents" --check "$tracked" > /dev/null || fail "check failed on a tracking project"
rm "$tracked/.claude/agents/"*.md
mkdir -p "$tracked/.claude/hooks"
cp "$ROOT/templates/.claude/hooks/sync-agents.sh" "$tracked/.claude/hooks/"
# The hook follows main, so serve the commit under test as main.
git clone -q "$ROOT" "$cache/source" && git -C "$cache/source" checkout -q -B main
BEST_PRACTICES_URL="file://$cache/source" XDG_CACHE_HOME="$cache" \
    bash "$tracked/.claude/hooks/sync-agents.sh" --strict > /dev/null || fail "the session hook failed to compose the roles"
[[ -f "$tracked/.claude/agents/core-agent.md" ]] || fail "the session hook did not write the roles"
grep -q '^ref:' "$tracked/.claude/agents/UPSTREAM" && fail "the session hook pinned a tracking project"
BEST_PRACTICES_URL="file:///nonexistent" XDG_CACHE_HOME="$(mktemp -d)" \
    bash "$tracked/.claude/hooks/sync-agents.sh" 2> /dev/null || fail "the session hook failed a session when offline"

exit $status
