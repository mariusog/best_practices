---
name: project-architecture
description: Use when deciding where to put code, choosing between patterns, designing module structure, or when user mentions architecture, code organization, or design patterns. Also use when the user wants to explore a codebase for architectural improvement, find refactoring opportunities, consolidate tightly-coupled modules, or deepen shallow modules. Guides both new architecture decisions and analysis of existing codebases; code examples use Python but principles are language-neutral.
---

# Project Architecture Patterns

> **Note**: Principles in this skill are language-neutral. Code examples use Python but the patterns (separate I/O from logic, functions over classes when stateless, etc.) apply to any language.

Evaluate, design, and improve the structural design of code. This skill covers two workflows:
1. **Design mode**: Architecture decisions for new projects, features, or modules
2. **Improve mode**: Exploring an existing codebase to surface friction and propose deepening refactors

## When to Use

**Design mode:**
- User asks "where should this code go?"
- A module is growing past its size limit
- You need to choose between functions, classes, mixins, or protocols
- You're designing a new feature that touches multiple modules
- You're reviewing whether a decomposition is sound

**Improve mode:**
- User wants to find refactoring opportunities in an existing codebase
- User asks to improve architecture, consolidate modules, or reduce coupling
- User wants to make a codebase more testable or easier to navigate

---

## Design Mode Workflow

### Step 1: Understand the Forces

Before proposing any structure, answer these questions:

1. **What changes together?** Group code by reason-to-change, not by technical layer.
2. **What are the dependencies?** Draw the import graph mentally. Cycles = structural problem.
3. **What needs to be tested independently?** If two things need different test setups, they belong in different modules.
4. **What is the performance contract?** Hot-path code has different structural constraints than cold-path code.

### Step 2: Evaluate Current Structure

Analyze the code using these metrics:

| Metric | Healthy | Unhealthy |
|--------|---------|-----------|
| Module size | < 300 lines | > 500 lines, multiple unrelated responsibilities |
| Class size | < 200 lines | God class doing everything |
| Import depth | ≤ 3 levels (warning at 4, unhealthy at 5+) | Deep chains: a -> b -> c -> d -> e |
| Circular imports | Zero | Any |
| Public surface area | Small, intentional | Everything is public |
| Coupling | Modules share interfaces, not internals | Module A reaches into Module B's data structures |

If all metrics are in the healthy range, report that the architecture is sound and no restructuring is needed. This is a valid outcome -- not every codebase needs refactoring. Note any minor opportunities but don't force changes.

### Step 3: Apply the Right Pattern

Use the decision frameworks below to choose the right structural pattern.

### Step 4: Validate the Design

After restructuring, verify:

- No circular imports (try importing the top-level package)
- Tests still pass (run the **Test (fast)** command from the CLAUDE.md Tooling table)
- No new lint issues (run linter on changed files)

---

## Improve Mode Workflow

Use this workflow when exploring an existing codebase for architectural improvements.

A **deep module** (John Ousterhout, "A Philosophy of Software Design") has a small interface hiding a large implementation. Deep modules are more testable, more navigable, and let you test at the boundary instead of inside.

### Step 1: Explore the Codebase

Navigate the codebase naturally. Do NOT follow rigid heuristics -- explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small files?
- Where are modules so shallow that the interface is nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called?
- Where do tightly-coupled modules create integration risk in the seams between them?
- Which parts of the codebase are untested, or hard to test?

The friction you encounter IS the signal.

Spend no more than 10-15 minutes on exploration. You're looking for friction, not building a complete map. If you haven't found friction after reading 10-15 files, the codebase may already be well-structured -- report that as a finding.

### Step 2: Present Candidates

Present 3-5 candidates, ranked by impact (most coupling/friction first). For each candidate, show:

- **Cluster**: Which modules/concepts are involved
- **Why they're coupled**: Shared types, call patterns, co-ownership of a concept
- **Dependency category**: See the Dependency Categories section below
- **Test impact**: What existing tests would be replaced by boundary tests

Do NOT propose interfaces yet. Ask the user: "Which of these would you like to explore?"

### Step 3: User Picks a Candidate

### Step 4: Design the Deepened Interface

For the chosen candidate, write:

- The constraints any new interface would need to satisfy
- The dependencies it would need to rely on
- A rough illustrative code sketch to make the constraints concrete

Then propose 2-3 interface alternatives with different trade-offs:

1. **Minimal interface**: 1-3 entry points max, hides the most complexity
2. **Flexible interface**: supports many use cases and extension
3. **Caller-optimized interface**: makes the most common use case trivial

For each alternative, provide:
- Interface signature (types, methods, params)
- Usage example showing how callers use it
- What complexity it hides internally
- Dependency strategy (how deps are handled -- see Dependency Categories)
- Trade-offs

Give your recommendation: which design is strongest and why. If elements from different designs combine well, propose a hybrid. Be opinionated -- the user wants a strong read, not just a menu.

### Step 5: Create GitHub Issue (Optional)

If the user wants to track the refactor, create a RFC as a GitHub issue using `gh issue create`. Use the RFC template below.

### Dependency Categories

When assessing a candidate for deepening, classify its dependencies:

**1. In-process**: Pure computation, in-memory state, no I/O. Always deepenable -- just merge the modules and test directly.

**2. Local-substitutable**: Dependencies that have local test stand-ins (e.g., PGLite for Postgres, in-memory filesystem). Deepenable if the test substitute exists.

**3. Remote but Owned (Ports & Adapters)**: Your own services across a network boundary. Define a port (interface) at the module boundary. The deep module owns the logic; the transport is injected. Tests use an in-memory adapter.

**4. True External (Mock)**: Third-party services (Stripe, Twilio, etc.) you don't control. Mock at the boundary. The deepened module takes the external dependency as an injected port.

### Testing Strategy for Deepened Modules

The core principle: **replace, don't layer.**

- Old unit tests on shallow modules are waste once boundary tests exist -- delete them
- Write new tests at the deepened module's interface boundary
- Tests assert on observable outcomes through the public interface, not internal state
- Tests should survive internal refactors -- they describe behavior, not implementation

### RFC Issue Template

```markdown
## Problem

Describe the architectural friction:

- Which modules are shallow and tightly coupled
- What integration risk exists in the seams between them
- Why this makes the codebase harder to navigate and maintain

## Proposed Interface

The chosen interface design:

- Interface signature (types, methods, params)
- Usage example showing how callers use it
- What complexity it hides internally

## Dependency Strategy

Which category applies and how dependencies are handled:

- **In-process**: merged directly
- **Local-substitutable**: tested with [specific stand-in]
- **Ports & adapters**: port definition, production adapter, test adapter
- **Mock**: mock boundary for external services

## Testing Strategy

- **New boundary tests to write**: describe the behaviors to verify at the interface
- **Old tests to delete**: list the shallow module tests that become redundant
- **Test environment needs**: any local stand-ins or adapters required

## Implementation Recommendations

Durable architectural guidance that is NOT coupled to current file paths:

- What the module should own (responsibilities)
- What it should hide (implementation details)
- What it should expose (the interface contract)
- How callers should migrate to the new interface
```

---

## Decision Framework: Where Does This Code Go?

Don't ask "what kind of code is this?" -- ask "what forces act on it?"

```
Does it have state that persists across calls?
+-- No -> Function in the module closest to its callers
|       (If called from only one place, keep it there. Don't extract prematurely.)
|
+-- Yes -> Does it share that state across multiple methods?
    +-- No -> Function with explicit state parameter
    |       def compute(state: State, pos: Position) -> Action
    |
    +-- Yes -> Class. Now ask:
        +-- Is it data with minimal behavior? -> @dataclass / struct / record
        +-- Is it a long-lived object with complex state? -> Regular class
        +-- Is it a capability that cross-cuts multiple classes? -> Mixin / trait
```

## Decision Framework: When to Split a Module

A module should split when it has **multiple independent reasons to change**. Not when it's "big" -- a 280-line module with one cohesive responsibility is better than three 100-line modules with tangled dependencies.

**Split into a package when:**
- The module has 3+ distinct responsibilities with different change cadences
- Different parts need different test infrastructure
- You want to hide internal structure behind public re-exports

**How to split:**
```
# BEFORE: data_state.py (500 lines, 4 responsibilities)

# AFTER: data_state/ package
data_state/
+-- __init__.py          # Re-exports public API
+-- _base.py             # Shared helpers, base class
+-- distance.py          # Distance computation
+-- assignment.py        # Entity-to-target assignment
+-- routing.py           # Multi-stop route optimization
```

Key rules:
- The public entry point re-exports the public API -- callers don't change
- Internal modules can use `_prefix` to signal they're private
- Each sub-module should be testable independently

## Decision Framework: Composition Patterns

### Functions (Default Choice)

Use when: no shared state, no configuration, pure input -> output.

```python
def find_shortest_path(start: Pos, goal: Pos, blocked: set[Pos]) -> int | None:
    """Stateless. Easy to test. Easy to compose."""
```

### Classes

Use when: shared mutable state across multiple methods, or when identity matters.

```python
class DataState:
    """Owns the data grid, caches, and per-round state.
    Multiple methods operate on the same internal data."""

    def __init__(self, width: int, height: int) -> None:
        self._grid = Grid(width, height)
        self._cache: dict[Pos, int] = {}

    def update(self, new_data: dict) -> None: ...
    def distance(self, a: Pos, b: Pos) -> int: ...
```

### Mixins

Use when: a class has grown large and its methods partition into independent capabilities that share `self`.

```python
class DistanceMixin:
    """Distance computation. Mixed into DataState."""

    def dist_static(self, a: Pos, b: Pos) -> int:
        # Uses self._grid, self._cache from the host class
        ...

class DataState(DistanceMixin, RoutingMixin, AssignmentMixin):
    """Composes capabilities via mixins."""
```

**Mixin rules:**
- Each mixin has one responsibility
- Mixins access only well-defined attributes of `self` (document which ones)
- Mixins don't depend on each other -- they depend on the base class
- The host class is the only place where mixins are composed
- Test each mixin through the composed class, not in isolation

### Protocols (Structural Subtyping)

Use when: you need polymorphism without inheritance. When multiple unrelated classes should satisfy the same interface.

```python
from typing import Protocol

class Simulator(Protocol):
    def step(self, actions: list[Action]) -> Result: ...
    def is_done(self) -> bool: ...

# LiveSimulator and ReplaySimulator both satisfy this
# without inheriting from a common base
```

**Protocol vs ABC decision:**
- Use Protocol when: consumers just need "anything with these methods" (duck typing made explicit)
- Use ABC when: you have shared implementation in the base class that subclasses inherit

## Dependency Direction

Dependencies should flow **inward** -- from I/O and entry points toward pure domain logic. Never the reverse.

```
Entry points (main.py, cli.py)
    | depends on
Orchestration (logic/, handlers/)
    | depends on
Domain logic (core/, algorithms/)
    | depends on
Pure data (constants, dataclasses)
```

**Rules:**
- Lower layers NEVER import from higher layers
- Constants/config imports nothing from the project
- Core algorithms import only from constants (or stdlib)
- Domain logic imports from core -- never the reverse
- Entry points import from everything -- nothing imports from entry points

**Detecting violations:**
```sh
# Check what a module imports from the project
grep -n "from src" src/algorithms/search.py
# If algorithms imports from logic/ -> dependency direction violation
```

## Module Cohesion Checklist

When reviewing a module, check:

- [ ] **Can you describe what it does in one sentence without "and"?** If not, it has multiple responsibilities.
- [ ] **Do all public functions/methods use roughly the same set of internal helpers?** If some functions use helpers A, B, C and others use D, E, F -- those are two modules.
- [ ] **Would a change to one function likely require changes to others in the same file?** High co-change = high cohesion = good.
- [ ] **Can you delete a public function without breaking anything else in the file?** If yes for many functions, cohesion is low -- it's a grab bag.

## Anti-Patterns and Remedies

| Anti-Pattern | Symptom | Remedy |
|---|---|---|
| **God class** | One class > 500 lines, does everything | Extract mixins or delegate to helper classes |
| **Shotgun surgery** | One change requires editing 5+ files | The scattered code belongs together -- consolidate |
| **Feature envy** | Method mostly accesses another object's data | Move the method to where the data lives |
| **Middle man** | Class that only delegates to another class | Remove it; let callers use the real thing directly |
| **Speculative generality** | ABC with one implementation, unused Protocol | Delete it. Add abstraction when the second use case arrives |
| **Circular dependency** | A imports B, B imports A | Extract shared types/interfaces into a third module, or merge |
| **Util junk drawer** | `utils` > 200 lines with unrelated functions | Split by domain or move functions to their callers |
| **Shallow module explosion** | Many small files where the interface is as complex as the implementation | Merge tightly-coupled modules into a deeper module with a smaller interface |

## Scaling Patterns

### When a function grows complex (> 30 lines)

Extract named helper functions in the same module. Don't create a new file for one helper.

### When a module grows large (> 300 lines)

1. Identify the 2-3 responsibilities
2. Check if they have different test needs
3. If yes: split into a package with public re-exports
4. If no: try extracting just the helper functions to a `_helpers` module

### When a class grows large (> 200 lines)

1. Identify method clusters that share internal state
2. Extract each cluster as a mixin
3. Keep initialization and coordination in the main class
4. Each mixin gets tested through the composed class

### When you need a new top-level module

Justify it: Does it have a distinct responsibility? Will multiple other modules import from it? If it's only used by one module, make it a private sub-module instead.

## Common Architectural Decisions

### State management: class instance vs module-level

| Factor | Class instance | Module-level |
|--------|---------------|--------------|
| Multiple instances needed | Yes -> class | No -> either works |
| Needs reset between runs | Class with `reset()` method | Module `reset()` function |
| Accessed from many modules | Class passed as parameter | Import the module |
| Performance-critical cache | Class attribute (co-located) | Module dict (slightly faster) |

### Configuration: constants vs config objects

- **Constants** (`ALL_CAPS` in constants file): values that change at development time, not runtime. Thresholds, sizes, feature flags.
- **Config dataclass**: values that change per-run or per-environment. Passed explicitly, never imported as globals.

### Error handling location

- **System boundaries** (I/O, user input, external APIs): validate and handle errors
- **Internal pure functions**: let exceptions propagate. Don't add try/except inside domain logic -- the caller decides how to handle failure.
- **Between layers**: convert low-level exceptions to domain-meaningful ones at layer boundaries

## Scoring (0-100)

Additive rubric -- start at 0, earn points for each criterion met:

| Criterion | Points |
|-----------|--------|
| Modules have clear single responsibility | 20 |
| Import depth within healthy range (<=4) | 15 |
| No circular dependencies | 15 |
| Dependency direction is correct (high->low) | 15 |
| Deep modules (simple interface, complex implementation) | 15 |
| Composition preferred over inheritance where appropriate | 10 |
| Anti-patterns identified and addressed | 10 |

| Score | Interpretation |
|-------|---------------|
| 90-100 | Healthy architecture -- no structural issues, clear module boundaries |
| 70-89 | Minor issues -- some coupling or shallow modules to address |
| 50-69 | Needs attention -- circular dependencies or unclear responsibilities |
| 0-49 | Significant problems -- deep structural issues requiring major refactoring |

## Completion

Report using this template:

```
## Architecture Review: <project or area>

- **Modules analyzed**: <N>
- **Issues found**:
  - <category>: <description>
  - ...
- **Recommendations**:
  - <recommendation 1>
  - <recommendation 2>
  - ...
- **Score: X/100**
```

## Gotchas

- **Recommending patterns the team doesn't know**: Introducing hexagonal architecture to a team that writes simple CRUD apps adds complexity without benefit. Match the architecture to the team's capabilities and the project's actual complexity.
- **Over-modularizing small projects**: A 5-file project doesn't need 3 abstraction layers. Start simple, split when you feel pain (files over 300 lines, too many reasons to change one module).
- **Splitting by technical layer when the domain says otherwise**: Organizing as `models/`, `services/`, `controllers/` scatters related code across directories. For domain-heavy apps, organize by feature (`auth/`, `payments/`, `notifications/`).
- **Proposing refactors that break all existing tests**: A "better" architecture that requires rewriting every test is a net negative. Propose changes that can be migrated incrementally, with existing tests still passing at each step.
- **Over-abstracting with one implementation**: Creating an interface or abstraction layer when only one concrete implementation exists adds complexity without benefit. Abstract when you have 2+ real implementations, not before.
- **Refactoring stable, working code**: Code that works, is tested, and rarely changes doesn't need architectural improvement regardless of how it looks. Focus on code that is actively causing friction.

## Related Skills

| Need | Skill |
|------|-------|
| Restructuring existing code | `refactor` |
| Evaluating code quality | `code-review` |
| Adding caching to hot paths | `caching-strategies` |
| Processing pipeline design | `data-pipeline` |
| Error handling patterns | `error-handling` |
