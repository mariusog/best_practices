#!/usr/bin/env bash
# .gitignore must include critical security and cache patterns.
ROOT="${1:-.}"
status=0
gitignore="$ROOT/templates/.gitignore"
for pattern in ".env" "__pycache__" ".ruff_cache" "*.pem" "*.key" "runs/" "data/" "weights/"; do
    if ! grep -qF "$pattern" "$gitignore"; then
        echo ".gitignore missing: $pattern"
        status=1
    fi
done
exit $status
