#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a new project from the best_practices template.
# Usage: ./bootstrap.sh <target-directory> [--lang python|typescript|go|rust|ruby]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANG="python"  # default

usage() {
    echo "Usage: $0 <target-directory> [--lang python|typescript|go|rust|ruby]"
    echo ""
    echo "Sets up a new project with best-practices structure:"
    echo "  - .claude/ directory (agents, skills)"
    echo "  - CLAUDE.md (project instructions)"
    echo "  - TASKS.md (task tracking)"
    echo "  - .gitignore"
    echo "  - Language-specific config (if available)"
    echo "  - Directory structure (src/, tests/, logs/, docs/)"
    echo ""
    echo "Options:"
    echo "  --lang    Language/stack (default: python)"
    echo "            Supported: python, typescript, go, rust, ruby"
    exit 1
}

# Parse arguments
if [[ $# -lt 1 ]]; then
    usage
fi

TARGET="$1"
shift

while [[ $# -gt 0 ]]; do
    case "$1" in
        --lang)
            LANG="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate language
case "$LANG" in
    python|typescript|go|rust|ruby) ;;
    *)
        echo "Error: Unsupported language '$LANG'. Use: python, typescript, go, rust, ruby"
        exit 1
        ;;
esac

# Create target directory
if [[ -d "$TARGET" ]]; then
    echo "Warning: $TARGET already exists. Files will be copied into it (existing files preserved)."
    read -p "Continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

echo "Bootstrapping project in: $TARGET"
echo "Language: $LANG"
echo ""

# 1. Copy .claude directory (agents + skills)
echo "[1/7] Copying .claude/ (agents and skills)..."
cp -rn "$SCRIPT_DIR/.claude" "$TARGET/" 2>/dev/null || cp -r "$SCRIPT_DIR/.claude" "$TARGET/"

# 2. Copy CLAUDE.md
echo "[2/7] Copying CLAUDE.md..."
if [[ ! -f "$TARGET/CLAUDE.md" ]]; then
    cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"
else
    echo "  CLAUDE.md already exists, skipping (update manually if needed)"
fi

# 3. Copy templates
echo "[3/7] Copying templates..."
cp -n "$SCRIPT_DIR/templates/.gitignore" "$TARGET/.gitignore" 2>/dev/null || true
cp -n "$SCRIPT_DIR/templates/TASKS.md" "$TARGET/TASKS.md" 2>/dev/null || true

# Copy Claude Code hooks
mkdir -p "$TARGET/.claude/hooks"
cp -n "$SCRIPT_DIR/templates/.claude/settings.json" "$TARGET/.claude/settings.json" 2>/dev/null || true
cp -n "$SCRIPT_DIR/templates/.claude/hooks/"* "$TARGET/.claude/hooks/" 2>/dev/null || true
chmod +x "$TARGET/.claude/hooks/"*.sh 2>/dev/null || true

# 4. Create directory structure
echo "[4/7] Creating directory structure..."
mkdir -p "$TARGET/src" "$TARGET/tests" "$TARGET/logs" "$TARGET/docs"

# 5. Language-specific setup
echo "[5/7] Setting up $LANG config..."
case "$LANG" in
    python)
        cp -n "$SCRIPT_DIR/templates/pyproject.toml" "$TARGET/pyproject.toml" 2>/dev/null || true
        cp -n "$SCRIPT_DIR/templates/conftest.py" "$TARGET/tests/conftest.py" 2>/dev/null || true
        cp -n "$SCRIPT_DIR/templates/constants.py" "$TARGET/src/constants.py" 2>/dev/null || true
        # Create __init__.py files
        touch "$TARGET/src/__init__.py"
        touch "$TARGET/tests/__init__.py"
        echo "  Copied: pyproject.toml, tests/conftest.py, src/constants.py"
        echo "  Created: src/__init__.py, tests/__init__.py"
        ;;
    typescript)
        echo "  Note: No TypeScript templates yet. Create package.json, tsconfig.json manually."
        echo "  Update the Project Tooling table in CLAUDE.md for TypeScript commands."
        ;;
    go)
        echo "  Note: No Go templates yet. Run 'go mod init <module>' manually."
        echo "  Update the Project Tooling table in CLAUDE.md for Go commands."
        ;;
    rust)
        echo "  Note: No Rust templates yet. Run 'cargo init' manually."
        echo "  Update the Project Tooling table in CLAUDE.md for Rust commands."
        ;;
    ruby)
        # Rails-style directory structure
        mkdir -p "$TARGET/app/models" "$TARGET/app/controllers" "$TARGET/app/services"
        mkdir -p "$TARGET/config" "$TARGET/db" "$TARGET/lib"
        mkdir -p "$TARGET/spec/models" "$TARGET/spec/controllers" "$TARGET/spec/services"
        mkdir -p "$TARGET/spec/support" "$TARGET/spec/factories"
        echo "  Created: app/{models,controllers,services}, config/, db/, lib/"
        echo "  Created: spec/{models,controllers,services,support,factories}"
        echo "  Update the Project Tooling table in CLAUDE.md for Ruby commands."
        ;;
esac

# 6. Initialize git if not already a repo
echo "[6/7] Checking git..."
if [[ ! -d "$TARGET/.git" ]]; then
    cd "$TARGET"
    git init -q
    echo "  Initialized git repository"
else
    echo "  Git repository already exists"
fi

# 7. Summary
echo "[7/7] Done!"
echo ""
echo "Project structure:"
echo "  $TARGET/"
echo "  +-- .claude/           # Agents, skills, hooks"
echo "  +-- src/               # Source code"
echo "  +-- tests/             # Test files"
echo "  +-- logs/              # Runtime logs (gitignored)"
echo "  +-- docs/              # Generated reports"
echo "  +-- CLAUDE.md          # Project instructions"
echo "  +-- TASKS.md           # Task tracking board"
echo "  +-- .gitignore"
case "$LANG" in
    python)
        echo "  +-- pyproject.toml     # Python config (ruff, mypy, pytest)"
        ;;
    ruby)
        echo "  +-- app/               # Application code (models, controllers, services)"
        echo "  +-- config/            # Configuration files"
        echo "  +-- db/                # Database migrations and schema"
        echo "  +-- lib/               # Library code"
        echo "  +-- spec/              # RSpec test files"
        ;;
esac
echo ""
echo "Next steps:"
echo "  1. cd $TARGET"
if [[ "$LANG" != "python" ]]; then
    echo "  2. Update the Project Tooling table in CLAUDE.md for $LANG"
fi
echo "  2. Update the File Ownership table in CLAUDE.md with your file paths"
echo "  3. Start working -- agents will read CLAUDE.md and TASKS.md automatically"
