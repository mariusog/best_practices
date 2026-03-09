# Project Best Practices

## Project Tooling

Configure these for your language/stack. All commands throughout this file and in agent configs reference these.

| Tool | Command | Notes |
|------|---------|-------|
| **Test (fast)** | `python -m pytest tests/ -q --tb=line -m "not slow" 2>&1 \| tail -20` | Pipe through tail. Use quiet mode. |
| **Test (debug)** | `python -m pytest tests/path/file.py::test_name -q --tb=short 2>&1 \| tail -40` | Only for investigating a specific failure. |
| **Lint** | `ruff check <files>` | Auto-fix: `ruff check --fix <files>` |
| **Format** | `ruff format <files>` | Check only: `ruff format --check <files>` |
| **Type check** | `mypy <files>` | |
| **Security scan** | `bandit -r . -ll` | Dependencies: `pip-audit` |
| **Log analysis** | `python analyze.py <log> --brief 2>&1 \| tail -15` | See Log-Reading Workflow below. |
| **Benchmark** | `python benchmark.py --diagnostics` | Results go to `docs/benchmark_results.md`. |
| **Constants file** | `src/constants.py` | All magic numbers and tuning parameters. |
| **Test fixtures** | `tests/conftest.py` | Shared factories and setup/teardown. |
| **Source extension** | `.py` | |

**To adapt for another language**: Replace the commands above. The rest of this file (principles, workflows, coordination) is language-neutral.

<details><summary>Common alternative stacks</summary>

| Tool | TypeScript/Node | Go | Rust |
|------|----------------|-----|------|
| Test (fast) | `npx jest --silent 2>&1 \| tail -20` | `go test ./... 2>&1 \| tail -20` | `cargo test 2>&1 \| tail -20` |
| Lint | `npx eslint <files>` | `golangci-lint run` | `cargo clippy` |
| Format | `npx prettier --write <files>` | `gofmt -w <files>` | `cargo fmt` |
| Type check | (built-in with tsc) | (built-in) | (built-in) |
| Security | `npm audit` | `govulncheck ./...` | `cargo audit` |
| Constants file | `src/constants.ts` | `internal/constants.go` | `src/constants.rs` |
| Test fixtures | `tests/helpers.ts` | `testutil/helpers.go` | `tests/common/mod.rs` |
| Source extension | `.ts` | `.go` | `.rs` |

</details>

## AI Agent Ground Rules

Read this section FIRST. These are the rules that save you from wasting tokens and making common mistakes.

### NEVER Do These

- **NEVER use verbose test output** -- use quiet mode and pipe through `tail`
- **NEVER read raw CSV log files** -- read `docs/benchmark_results.md` first, use the analysis tool for drill-down
- **NEVER parse stdout to extract results** -- read the generated report files instead
- **NEVER use JSON lines for high-volume data** -- use CSV (4x more token-efficient)
- **NEVER use bare print/console.log for operational output** -- use the language's logging framework
- **NEVER dump full file contents when a summary exists** -- read summaries first, drill down on demand
- **NEVER use unseeded randomness** -- all randomized code MUST accept a `seed` parameter
- **NEVER modify files owned by another agent** -- add a task to `TASKS.md` instead

### ALWAYS Do These

- **ALWAYS pipe command output through `tail`** -- bound your token consumption
- **ALWAYS read TASKS.md before starting work** -- claim a task, set it to `in-progress`
- **ALWAYS run tests before committing** -- zero tolerance for test failures
- **ALWAYS include before/after metrics** when reporting optimization results
- **ALWAYS log the seed** in every run so results can be replicated

### Token Budget Awareness

You are an AI agent with a finite context window. Optimize for it:

| Action | Token-Efficient Way | Token-Wasteful Way |
|--------|--------------------|--------------------|
| Check test results | Fast test command from Tooling table | Verbose test output (unbounded) |
| Read benchmark results | `cat docs/benchmark_results.md` | Parse stdout from benchmark run |
| Inspect a log | Analysis tool with `--brief` | Read the raw CSV file |
| Compare two runs | Analysis tool with `--compare` | Read both files and diff manually |
| Understand entity behavior | `--entity <id> --brief` (compressed) | Read 200 rows of per-step data |
| Check for problems | `--problems` (anomalies only) | Read full summary + all data |

### Codebase Orientation (when starting in a new project)

When dropped into an unfamiliar codebase, read in this order:

1. **CLAUDE.md** -- this file (project rules, structure, conventions)
2. **TASKS.md** -- what work is in progress, what's done, what's open
3. **Project structure** -- `ls` the source and test directories
4. **Constants file** -- all tuning parameters and configuration values
5. **Test fixtures** -- understand the shared setup and factory functions
6. **The specific files related to your task** -- only then dive into source code

Do NOT read every file. Read the minimum needed for your task.

### Skill Selection Guide

After writing or modifying code, use this decision tree:

```
Did you write new code?
+-- Yes: Run test-coverage (verify tests exist for new public methods)
+-- Did tests fail?
|   +-- Yes: Run debugging skill. Do NOT proceed until green.
+-- Is this a performance-sensitive change?
|   +-- Yes: Run performance-optimization
+-- Ready to ship?
|   +-- Yes: Run production-quality (orchestrates all quality skills)
+-- Quick quality check only?
    +-- Yes: Run lint + code-review
```

For new features, use `tdd-cycle` (write tests first, then implement).

## Project Structure

Adapt to your language. The key principle: **source and test directories mirror each other**.

```
your_project/
+-- src/                        # Main package
|   +-- constants.*             # Named constants (tuning parameters)
|   +-- ...                     # Your modules
+-- tests/
|   +-- fixtures/helpers        # Shared test setup and factories
|   +-- ...                     # Mirror source structure exactly
+-- logs/                       # Runtime logs and debug data
+-- docs/                       # Generated reports (benchmark_results.md)
+-- CLAUDE.md                   # This file
+-- TASKS.md                    # Task tracking board
```

## Code Quality Standards

### Hard Limits

- **300 lines max per file** (source and test)
- **200 lines max per class/struct/module**
- **30 lines max per method/function** (excluding doc comments)
- **No magic numbers** -- all thresholds in the constants file
- **Type annotations required** on all public function signatures (where the language supports it)

### SOLID Principles

- **SRP**: Every class/function has one responsibility. If you can say "and", split it.
- **OCP**: Behavior is extensible without modifying existing code.
- **LSP**: Subtypes are drop-in replacements for their base types.
- **ISP**: Specific imports only. No wildcard imports.
- **DIP**: High-level modules depend on abstractions, not low-level implementation details.

### Law of Demeter

- Max one level of chaining: `self.state.getDistance()` OK, `self.state.cache[pos].get(target)` NOT OK.

### Safety

- All search/exploration functions have bounded iteration (`maxSteps`, `maxCells`, etc.)
- No unbounded loops or recursion without explicit depth limits
- Validate at system boundaries: positions within bounds, inputs within limits

## Testing Standards

### Coverage Requirements

**Every public method and function MUST have at least one dedicated test.** Non-negotiable.

Test naming: `test_<method_name>_<scenario>` -- e.g., `test_calculate_score_empty_input_returns_zero`

### Unit Test Checklist (per method)

1. **Happy path** -- normal input, expected output
2. **Edge cases** -- empty inputs, zero values, boundary conditions
3. **Error conditions** -- invalid input, unreachable targets, overflow
4. **State mutations** -- verify side effects

### Test Quality Rules

- **Arrange-Act-Assert** pattern in every test
- **One assertion per concept** -- test one behavior, not five
- **No test interdependence** -- each test creates its own state via fixtures/factories
- **Deterministic** -- no random inputs without fixed seeds
- **Descriptive names** -- `test_search_stops_at_max_depth` not `test_search_1`

### Reproducibility

- All randomized processes MUST accept a `seed` parameter
- Benchmark runs MUST be reproducible with the same seed
- Log the seed in every run so results can be replicated
- Test data must be deterministic -- use factory functions, not random generators

### Running Tests

Use the **Test (fast)** command from the Tooling table. When debugging a failure, use **Test (debug)**.

**IMPORTANT**: Always use quiet mode and pipe through `tail`. Never use verbose output.

### When Tests Fail

1. Read the failure output (the `tail` you already have)
2. If the error is clear, fix it and rerun
3. If unclear, rerun the single failing test with more detail (see Test debug command)
4. If the failure is in another agent's code, do NOT fix it -- add a task to TASKS.md
5. If a test is flaky (passes sometimes, fails sometimes), it has a non-determinism bug -- fix the seed

## Logging and Debug Data

### Token-Efficient Log Formats

| Data Type | Format | Why |
|-----------|--------|-----|
| Per-step tabular data | **CSV** (short column names) | Headers once, 4x cheaper than JSON lines |
| Run metadata | **JSON** | One-off, structured, small |
| Pre-computed summaries | **Markdown** | Agents read directly as files |

- **NEVER** use JSON lines for high-volume per-step data (keys repeat every row)
- Use short CSV column names: `s,eid,x,y,act,score` not `step_number,entity_id,...`
- Log files go in `logs/` with timestamps: `<name>_<YYYY-MM-DD_HH-MM-SS>.{csv,json}`

### Three-Tier Log Architecture

1. **Tier 1 -- Summary report** (agents read this FIRST): Pre-computed markdown in `docs/benchmark_results.md`. Contains scores, key metrics, auto-detected problems. Under 40 lines.
2. **Tier 2 -- CSV detail log**: Per-step data in `logs/`. Agents drill into this ONLY when Tier 1 flags a problem. Never read raw CSV directly -- use the analysis tool.
3. **Tier 3 -- JSON metadata**: Config, seed, environment. One file per run.

### Agent Log-Reading Workflow

```sh
# Step 1: Read the summary FIRST (5-15 lines)
cat docs/benchmark_results.md

# Step 2: If problems, get the anomaly list (use Log analysis command from Tooling table)
<log_analysis_command> <log> --problems 2>&1 | tail -20

# Step 3: Drill into a specific entity
<log_analysis_command> <log> --entity 3 --brief 2>&1 | tail -15

# Step 4: Only if still unclear, look at raw step range
<log_analysis_command> <log> --steps 40-50 2>&1 | tail -20
```

Agents should almost NEVER need to go past Step 2.

### Visualization

- **Text-only**: ASCII grids, markdown tables, compact summaries
- Agents can't open browsers or view images -- all debug tools must work in terminal
- Visualization reads from log files -- never couple to runtime
- Run-length encode timelines: `move x12 | pickup | move x5 | deliver x3`

## Benchmarking

- Write results to `docs/benchmark_results.md` -- agents read the file, NEVER parse stdout
- Always run with `--diagnostics` after optimization changes
- Include before/after scores and problem counts in task notes
- Use multiple seeds for statistical comparison (10+ seeds recommended)
- Comparisons MUST use the same seed list to be valid
- Report only changed metrics in diffs (skip unchanged values to save tokens)

## Multi-Agent Coordination Protocol

When multiple agents run in parallel (via worktrees), they MUST follow this protocol.

### Task Workflow

1. Read `TASKS.md` -- see what's available, claimed, and done
2. Claim a task matching your role -- set status to `in-progress`, add your agent name
3. Do the work -- stay in your lane (only modify your owned files)
4. Run tests -- all must pass before committing
5. Update `TASKS.md` -- set status to `done`, add result note in this format:

```
Result: <what changed> | <metric before> -> <metric after> | <tests: pass/fail>
```

Example: `Result: Added idle timeout | idle_pct: 15% -> 3% | tests: 432 pass`

### Task Result Format

Every completed task MUST report:
- **What changed**: One sentence describing the code change
- **Metrics**: Before/after numbers for the targeted metric
- **Tests**: Pass count, any new tests added
- **Problems**: Any issues discovered for other agents (add as new tasks)

### Conflict Prevention

- Never claim a task already marked `in-progress`
- If you discover work in another agent's files, add a task -- do NOT modify their files
- QA Agent benchmarks AFTER other agents commit, not in parallel with active changes
- One task at a time -- finish or abandon before claiming another

## File Ownership

| Agent | Owned Files | Role |
|-------|-------------|------|
| lead-agent | Entry points, constants, `TASKS.md`, `CLAUDE.md`, `.claude/agents/` | Architecture, cross-cutting changes, task design |
| core-agent | Core algorithm and data modules | Algorithms, data structures, computation |
| feature-agent | Feature/business logic modules | Decision logic, workflows, rules |
| qa-agent | `tests/`, benchmarks, `docs/` | Testing, benchmarking, profiling |

The lead-agent has cross-cutting authority -- it may modify any file when a fix spans multiple agents' boundaries.

## Git Conventions

### Commit Messages

- Short, single-sentence, present tense: `Fix cache invalidation on round reset`
- Focus on WHY, not WHAT: `Prevent stale distances after entity moves` not `Change line 42 in distance.py`
- One logical change per commit

### Staging

- **Stage specific files by name** -- never use `git add .` or `git add -A` (risks committing secrets, logs, cache files)
- Check `git status` before committing -- verify only intended files are staged
- Never commit files matching `.gitignore` patterns

### Branches

- `main` is the stable branch -- all tests pass, benchmarks meet baselines
- Feature branches: `<agent>/<task-id>-<short-description>` e.g. `core/T12-cache-invalidation`
- Never force-push to `main`

## Bootstrapping This Template

### Quick Start (automated)

```bash
./bootstrap.sh /path/to/new-project --lang python
```

This copies the full structure, creates directories, and sets up language-specific config. Supported languages: `python`, `typescript`, `go`, `rust`.

### Manual Setup

1. Copy `.claude/` into your project root
2. Copy this CLAUDE.md -- update the **Project Tooling** table for your language/stack
3. Replace the **Project Structure** section with your actual layout
4. Copy `templates/.gitignore` (adapt language-specific patterns)
5. Copy `templates/TASKS.md` for task tracking
6. If Python: copy `templates/pyproject.toml`, `templates/conftest.py`, `templates/constants.py`
7. If other language: create equivalent config, test fixtures, and constants files
8. If using Claude Code hooks: copy `templates/.claude/settings.json` and `templates/.claude/hooks/`
9. Copy `templates/.github/workflows/ci.yml` for CI pipeline (adapt commands to match your Tooling table)
10. Update the **File Ownership** table with your actual file paths
