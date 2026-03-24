#!/usr/bin/env bash
set -euo pipefail

# Install Python dev dependencies
pip install --upgrade pip
pip install -e ".[dev]" 2>/dev/null || pip install -r requirements.txt 2>/dev/null || true

echo "DevContainer ready — node $(node --version), python $(python --version)"
