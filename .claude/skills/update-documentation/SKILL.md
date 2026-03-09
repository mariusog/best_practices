---
name: update-documentation
description: Update project documentation to reflect code changes. Reviews README, docstrings, and technical documentation. Use when the user asks to update docs, document changes, or sync documentation.
---

# Update Documentation Skill

Ensure project documentation accurately reflects code changes.

## Scope

This skill applies to files changed in the current branch compared to `main` (or `origin/main`).
Identify changed files with: `git diff --name-only origin/main...HEAD`

## Step 1: Analyze Changes

### Categorize Changes
- **New features**: Requires documentation of new functionality
- **API/interface changes**: Requires updated function/class docs
- **Architecture changes**: Requires updated design docs
- **Configuration changes**: Requires updated setup docs
- **Dependency changes**: Requires updated requirements docs
- **Algorithm changes**: Requires updated algorithm docs or comments

## Step 2: Docstring Updates

### Function/Method Docstrings
- Public functions have clear docstrings
- Parameters and return values documented
- Complex algorithms have explanatory comments

```python
def optimize_route(positions, constraints, seed=None):
    """Find optimal visit order using TSP heuristic.

    Args:
        positions: List of (x, y) coordinates to visit.
        constraints: Dict of constraint parameters.
        seed: Random seed for reproducibility. If None, uses system random.

    Returns:
        Reordered list of positions in optimal visit sequence.
    """
```

## Step 3: README Updates

- New dependencies or system requirements
- Changed installation steps
- New commands or CLI options
- New configuration options

## Step 4: Architecture / Design Docs

If design documents exist:
- Verify they reflect current implementation
- Mark completed items
- Update diagrams or descriptions

## Step 5: Dependencies

If dependencies changed:
- Update `requirements.txt` or `pyproject.toml`
- Document why new dependencies were added

## Step 6: Inline Documentation

### Algorithm Documentation
- Complex algorithms have comments explaining the approach
- Time/space complexity noted for critical functions
- Non-obvious optimizations explained

### Configuration Documentation
- Constants have comments explaining their purpose and tuning
- Magic numbers are named and documented

## Completion

Report:
- Documentation files updated
- Docstrings added or updated
- Areas that may need future documentation work
