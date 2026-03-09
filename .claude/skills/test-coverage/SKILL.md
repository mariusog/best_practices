---
name: test-coverage
description: Ensure adequate test coverage for changed code. Identifies relevant tests, runs them, and checks coverage. Use when the user asks to check test coverage, run tests, or verify specs.
---

# Test Coverage Skill

Ensure changed code has adequate test coverage and all tests pass.

## Scope

This skill applies to files changed in the current branch compared to `main` (or `origin/main`).
Identify changed files with: `git diff --name-only origin/main...HEAD`

## Step 1: Identify Relevant Tests

For each changed file, find corresponding test files:

### Mapping Source to Tests
- `src/module.py` -> `tests/test_module.py`
- `src/package/module.py` -> `tests/package/test_module.py`

Use grep to find test references:
```bash
grep -r "from module import\|import module" tests/
```

## Step 2: Baseline Test Run

Run identified tests to ensure we start green:
```bash
python -m pytest <test files> -q --tb=line 2>&1 | tail -20
```

If tests fail:
- **STOP** -- Do not proceed with other quality steps
- Report failing tests to the user
- Broken tests must be fixed before continuing

## Step 3: Coverage Analysis

For each changed file, verify test coverage:

### Check for Missing Tests
- Does every new public function have a corresponding test?
- Are new classes covered by tests?
- Are new algorithms tested with representative inputs?

### Check for Missing Scenarios
For existing tests, verify coverage of:
- **Happy path** -- normal operation
- **Edge cases** -- empty inputs, boundary values, None/zero
- **Error paths** -- invalid inputs, unreachable goals, timeouts
- **State transitions** -- before/after mutations
- **Determinism** -- same input always produces same output

### Add Missing Tests
If coverage is insufficient:
1. Write unit tests for new/changed public functions
2. Write integration tests for new workflows
3. Add edge case and error path tests
4. Use `@pytest.mark.parametrize` for multiple input scenarios

### Coverage Tool
```bash
python -m pytest --cov=src --cov-report=term-missing tests/ -q 2>&1 | tail -30
```

## Step 4: Run Full Test Suite

```bash
python -m pytest tests/ -q --tb=line -m "not slow" 2>&1 | tail -20
```

Ensure all tests pass before completing.

## Step 5: Verify No Regressions

If refactoring was done alongside coverage work:
- Run the full test suite to catch regressions
- Check that no existing tests were broken
- Verify benchmark scores haven't degraded (if applicable)

## Completion

Report:
- Number of test files identified
- Number of tests run
- Pass/fail status
- Any new tests added
- Coverage gaps that still need attention
