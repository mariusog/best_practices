#!/usr/bin/env bash
# Verify template config files are parseable.
ROOT="${1:-.}"
status=0

# CI workflow must be valid YAML
if ! python3 -c "import yaml; yaml.safe_load(open('$ROOT/templates/.github/workflows/ci.yml'))" 2>/dev/null; then
    echo "ci.yml: invalid YAML"
    status=1
fi

# settings.json must be valid JSON
if ! python3 -c "import json; json.load(open('$ROOT/templates/.claude/settings.json'))" 2>/dev/null; then
    echo "settings.json: invalid JSON"
    status=1
fi

# devcontainer.json must be valid JSON (after stripping comments)
if ! python3 -c "
import re, json
content = open('$ROOT/templates/.devcontainer/devcontainer.json').read()
content = re.sub(r'//.*$', '', content, flags=re.MULTILINE)
json.loads(content)
" 2>/dev/null; then
    echo "devcontainer.json: invalid JSON"
    status=1
fi

# pyproject.toml must be valid TOML
if ! python3 -c "import tomllib; tomllib.load(open('$ROOT/templates/pyproject.toml', 'rb'))" 2>/dev/null; then
    echo "pyproject.toml: invalid TOML"
    status=1
fi

exit $status
