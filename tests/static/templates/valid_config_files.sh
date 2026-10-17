#!/usr/bin/env bash
# Verify template config files are parseable.
ROOT="${1:-.}"
status=0

# CI workflow must be valid YAML. PyYAML isn't in Python's standard library,
# so fall back to Ruby's bundled Psych, and say so when neither parser exists
# instead of reporting the file as invalid.
ci="$ROOT/templates/.github/workflows/ci.yml"
if python3 -c "import yaml" 2>/dev/null; then
    yaml_check=(python3 -c "import sys, yaml; yaml.safe_load(open(sys.argv[1]))" "$ci")
elif command -v ruby > /dev/null; then
    yaml_check=(ruby -ryaml -e "YAML.safe_load(File.read(ARGV[0]), aliases: true)" "$ci")
else
    yaml_check=()
    echo "ci.yml: no YAML parser available (install PyYAML or Ruby)"
    status=1
fi
if [[ ${#yaml_check[@]} -gt 0 ]] && ! "${yaml_check[@]}" > /dev/null 2>&1; then
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
