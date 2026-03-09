---
name: python-architecture
description: Guides project architecture decisions and patterns, with Python examples. The principles (separation of concerns, module organization, when to abstract) apply to any language. Use when deciding where to put code, choosing between patterns, designing module structure, or when user mentions architecture, code organization, or design patterns.
---

# Project Architecture Patterns

> **Note**: Principles in this skill are language-neutral. Code examples use Python but the patterns (separate I/O from logic, functions over classes when stateless, etc.) apply to any language.

## Architecture Decision Tree

```
Where should this code go?
|
+-- Is it a pure algorithm (search, optimization, math)?
|   -> Dedicated module (e.g., pathfinding.py, optimizer.py)
|
+-- Is it data transformation or processing?
|   -> Pipeline module or function chain
|
+-- Is it configuration or constants?
|   -> constants.py or config.py
|
+-- Is it shared utility logic?
|   -> utils.py (keep small) or domain-specific module
|
+-- Is it I/O (files, network, database)?
|   -> Separate I/O module, keep business logic pure
|
+-- Is it test infrastructure?
|   -> conftest.py or test helpers module
|
+-- Is it a CLI entry point?
|   -> __main__.py or cli.py
|
+-- Is it logging/diagnostics?
    -> Dedicated diagnostics module
```

## Module Organization

### Small Project (< 10 files)
```
project/
+-- main.py
+-- core.py
+-- constants.py
+-- tests/
|   +-- conftest.py
|   +-- test_core.py
+-- pyproject.toml
```

### Medium Project (10-30 files)
```
project/
+-- src/
|   +-- __init__.py
|   +-- main.py
|   +-- core/
|   +-- logic/
|   +-- constants.py
|   +-- utils.py
+-- tests/
|   +-- conftest.py
|   +-- core/
|   +-- logic/
+-- logs/
+-- docs/
+-- pyproject.toml
```

## Core Principles

### 1. Separate Pure Logic from I/O

```python
# GOOD: Pure function -- easy to test
def decide_actions(state: dict) -> list[dict]:
    ...

# GOOD: I/O wrapper calls pure logic
async def run():
    async for message in websocket:
        state = json.loads(message)
        actions = decide_actions(state)
        await websocket.send(json.dumps(actions))
```

### 2. Functions Over Classes (When Appropriate)

```python
# BAD: Unnecessary class
class PathFinder:
    def __init__(self):
        pass
    def find_path(self, start, goal, blocked):
        return bfs(start, goal, blocked)

# GOOD: Just a function
def find_path(start, goal, blocked):
    return bfs(start, goal, blocked)
```

Use classes when you have shared state, multiple instances, or need inheritance.

### 3. Dataclasses for Structured Data

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Position:
    x: int
    y: int

@dataclass
class BotState:
    id: int
    position: Position
    inventory: list[str]
```

### 4. Module-Level State (With Care)

```python
_dist_cache: dict[tuple, dict] = {}

def get_distances(source):
    if source not in _dist_cache:
        _dist_cache[source] = compute_all(source)
    return _dist_cache[source]

def reset():
    """Call between sessions."""
    _dist_cache.clear()
```

### 5. Type Hints for Public APIs

```python
from typing import Optional

def find_best_target(
    pos: tuple[int, int],
    items: list[dict],
    blocked: set[tuple[int, int]],
) -> Optional[tuple[dict, float]]:
    """Find closest reachable item. Returns (item, distance) or None."""
```

## When NOT to Abstract

| Situation | Keep It Simple |
|-----------|----------------|
| Used only once | Inline the code |
| Simple function < 10 lines | Keep in current file |
| One-off data transform | List comprehension |
| Simple config | Module constants |

## When TO Abstract

| Signal | Action |
|--------|--------|
| Same code in 3+ places | Extract to shared function |
| Module > 300 lines | Split into focused modules |
| Function > 30 lines | Extract helper functions |
| Complex conditionals | Extract to strategy dict or function |

## Anti-Patterns

| Anti-Pattern | Solution |
|--------------|----------|
| God module (one file with everything) | Split by responsibility |
| Premature abstraction (ABC for 1 impl) | Use a plain function |
| Global mutable state everywhere | Limit scope, provide reset |
| Stringly typed (magic strings) | Use enums or constants |
| Nested dict soup (`data["a"]["b"]["c"]`) | Use dataclasses or TypedDict |
| Import-time side effects | Defer to explicit init function |

## Testing Strategy by Module Type

| Module Type | Test Approach | Focus |
|-------------|---------------|-------|
| Pure functions | Direct unit tests | Input -> output correctness |
| Algorithms | Parametrized tests | Edge cases, complexity |
| State management | Setup/teardown fixtures | State transitions |
| I/O wrappers | Mocks and integration tests | Error handling |
| CLI entry points | subprocess or click testing | Argument parsing |
