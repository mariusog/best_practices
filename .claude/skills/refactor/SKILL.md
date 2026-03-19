---
name: refactor
description: Refactor code for clarity and maintainability. Includes control flow improvements, constant extraction, and comment cleanup. Use when the user asks to refactor code, clean up code, or improve code structure.
---

# Refactor Skill

Improve code clarity and maintainability through targeted refactoring.

## Scope

This skill applies to files changed in the current branch compared to `main` (or `origin/main`).
Identify changed files with: `git diff --name-only origin/main...HEAD`

## Step 1: Control Flow Refactoring

### Replace Conditionals with Dictionaries
```python
# Before
def status_color(status):
    if status == "success":
        return "green"
    elif status == "warning":
        return "yellow"
    elif status == "error":
        return "red"
    else:
        return "gray"

# After
STATUS_COLORS = {"success": "green", "warning": "yellow", "error": "red"}

def status_color(status):
    return STATUS_COLORS.get(status, "gray")
```

### Use Early Returns
```python
# Before
def process(data):
    if data is not None:
        if data.is_valid():
            # long processing logic
            pass

# After
def process(data):
    if data is None:
        return
    if not data.is_valid():
        return
    # long processing logic
```

### Simplify with Language Idioms
```python
# Before
result = []
for item in items:
    if item.is_active():
        result.append(item.name)

# After
result = [item.name for item in items if item.is_active()]
```

## Step 2: Extract Constants

### Magic Numbers
```python
# Before
def calculate_score(value):
    return value * 1.15 + 50

# After
SCORE_MULTIPLIER = 1.15
BASE_SCORE_BONUS = 50

def calculate_score(value):
    return value * SCORE_MULTIPLIER + BASE_SCORE_BONUS
```

### Placement Guidelines
- Module-level constants: ALL_CAPS at the top of the module
- Shared constants: Dedicated `constants.py` module
- Configuration values: Environment variables or config files

## Step 3: Comment Cleanup

### Remove Unnecessary Comments
Delete comments that:
- Simply describe what the code does (code should be self-documenting)
- Restate the function name or variable name
- Are outdated or no longer accurate
- Are commented-out code

### Keep Valuable Comments
Preserve comments that:
- Explain WHY something is done a certain way
- Document non-obvious business logic or algorithm choices
- Warn about edge cases or gotchas
- Reference external documentation or tickets

## Step 4: File and Naming Conventions

Follow your language's standard naming conventions. Common principles:
- **Modules/files**: lowercase, consistent with language convention
- **Classes/types**: PascalCase (most languages)
- **Functions/variables**: camelCase or snake_case (per language convention)
- **Constants**: UPPER_SNAKE_CASE (most languages)
- **Private/internal**: use the language's visibility mechanism (underscore prefix, `private` keyword, unexported names, etc.)
- **Test files**: follow the test framework's naming convention

## Step 5: Verify Changes

After refactoring, use the commands from the CLAUDE.md Tooling table:
1. Run **Test (fast)** to confirm no regressions
2. Run **Lint** to confirm no style issues

## Completion

Report:
- Number of control flow improvements made
- Number of constants extracted
- Number of comments cleaned up
- Any areas that could benefit from further refactoring
