#!/usr/bin/env bash
# Hook scripts must be executable.
ROOT="${1:-.}"
status=0
for hook in "$ROOT"/templates/.claude/hooks/*.sh; do
    [ -f "$hook" ] || continue
    if [ ! -x "$hook" ]; then
        echo "$(basename "$hook"): not executable"
        status=1
    fi
done
exit $status
