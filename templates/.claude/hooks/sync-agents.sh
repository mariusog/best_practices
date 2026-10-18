#!/usr/bin/env bash
set -uo pipefail

# Compose this project's shared agent roles in .claude/agents/ from
# best_practices main plus .claude/agent-context/. The roles are generated and
# gitignored, never committed, so a role change in best_practices reaches the
# project without a PR.
#
# Runs when the devcontainer is created (so the first session has its agents)
# and as a SessionStart hook. Claude Code reads .claude/agents/ before that hook
# runs, so the hook refreshes the roles for the next session.
#
# Usage: .claude/hooks/sync-agents.sh [--strict]
#   Without --strict it never fails: offline, the project keeps the roles it
#   last composed. --strict (for CI) fetches every time and fails on any error.

PROJECT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REPO_URL="${BEST_PRACTICES_URL:-https://github.com/mariusog/best_practices.git}"
BRANCH="${BEST_PRACTICES_REF:-main}"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/best_practices"
FETCH_EVERY_SECS=600
FETCH_TIMEOUT_SECS=20

strict=0
[[ "${1:-}" == "--strict" ]] && strict=1

# A project that pins a commit (a `ref:` line in UPSTREAM) re-syncs by hand.
manifest="$PROJECT/.claude/agents/UPSTREAM"
if [[ ! -f "$manifest" ]] || grep -q '^ref:' "$manifest"; then exit 0; fi

soft_fail() {
    echo "sync-agents: $1" >&2
    [[ $strict -eq 1 ]] && exit 1
    exit 0
}

with_timeout() {
    if command -v timeout > /dev/null; then timeout "$FETCH_TIMEOUT_SECS" "$@"; else "$@"; fi
}

fetched_recently() {
    local stamp="$CACHE/.git/FETCH_HEAD" mtime
    [[ -f "$stamp" ]] || return 1
    mtime="$(stat -c %Y "$stamp" 2> /dev/null || stat -f %m "$stamp")"
    (( $(date +%s) - mtime < FETCH_EVERY_SECS ))
}

if [[ ! -d "$CACHE/.git" ]]; then
    mkdir -p "$(dirname "$CACHE")"
    with_timeout git clone -q --depth 1 --branch "$BRANCH" "$REPO_URL" "$CACHE" 2> /dev/null ||
        soft_fail "can't clone $REPO_URL; no shared agent roles this session"
    touch "$CACHE/.git/FETCH_HEAD"
elif [[ $strict -eq 1 ]] || ! fetched_recently; then
    if with_timeout git -C "$CACHE" fetch -q --depth 1 origin "$BRANCH" 2> /dev/null; then
        git -C "$CACHE" reset -q --hard FETCH_HEAD
    elif [[ $strict -eq 1 ]]; then
        soft_fail "can't fetch $REPO_URL"
    else
        echo "sync-agents: can't reach best_practices; keeping the roles from $(git -C "$CACHE" rev-parse --short HEAD)" >&2
    fi
fi

"$CACHE/bin/sync-agents" "$PROJECT" --ref HEAD > /dev/null || soft_fail "composing the agent roles failed"
if [[ $strict -eq 1 ]]; then
    "$CACHE/bin/sync-agents" --check "$PROJECT"
fi
