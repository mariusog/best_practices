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

Source and test directories should mirror each other. For example:
- `src/module` -> `tests/test_module`
- `src/package/module` -> `tests/package/test_module`

Use grep to find test references to your module in the test directory.

## Step 2: Baseline Test Run

Run identified tests using the **Test (fast)** command from the CLAUDE.md Tooling table to ensure we start green.

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
4. Use parameterized tests for multiple input scenarios

### Coverage Tool

Use your language's coverage tool to identify untested code paths. Check the CLAUDE.md Tooling table for the project-specific command.

## Step 4: Run Full Test Suite

Run the **Test (fast)** command from the CLAUDE.md Tooling table. Ensure all tests pass before completing.

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
