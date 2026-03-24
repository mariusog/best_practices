# Setup Test Prompts

Test prompts for verifying that agents and skills work correctly in your project. Run each prompt in Claude Code and check that the result matches expectations.

Update these prompts to match your project's actual files, modules, and domain.

## Agent Tests

### Lead Agent

```
Run as the lead-agent. The goal is: add input validation to the API endpoint.
```

**Expected behavior:**
- Checks that agent configs have been filled in (not placeholders)
- Reads CLAUDE.md, source structure, existing tests
- Creates tasks in TASKS.md with assignments
- Writes detailed checklists in per-agent plan files
- Spawns worker agents as worktree subagents

### Core Agent

```
Run as the core-agent. Optimize the search function in src/algorithms/search.py.
```

**Expected behavior:**
- Reads TASKS-core.md for assignments
- Profiles the function before changing it
- Documents time complexity
- Runs tests, reports results in plan file

### Feature Agent

```
Run as the feature-agent. Add retry logic to the API client in src/handlers/client.py.
```

**Expected behavior:**
- Reads TASKS-feature.md for assignments
- Writes test first (TDD), then implements
- Logs decision rationale
- Reports results in plan file

### QA Agent

```
Run as the qa-agent. Audit src/handlers/ for test coverage gaps.
```

**Expected behavior:**
- Lists all public methods in the target directory
- Cross-references with existing tests
- Identifies untested methods and edge cases
- Writes missing tests
- Reports audit summary table

### Researcher Agent

```
Run as the researcher-agent. What's the best approach for caching API responses with varying TTLs?
```

**Expected behavior:**
- Checks if Domain Expertise / Project Context are configured (prompts user if not)
- Searches for evidence (docs, papers, open-source examples)
- Presents findings with sources
- Gives actionable recommendation tied to project constraints

## Skill Tests

### tdd-cycle

```
Use the tdd-cycle skill. Write a function that validates email addresses.
```

**Expected behavior:** Writes a failing test first, then implements, then refactors.

### code-review

```
Use the code-review skill. Review src/handlers/ for correctness and quality issues.
```

**Expected behavior:** Checks for bugs, SOLID violations, performance issues. Reports severity.

### security-scan

```
Use the security-scan skill. Run a full security scan on this project.
```

**Expected behavior:** Runs bandit + pip-audit, checks for hardcoded secrets, reports score.

### open-source-audit

```
Use the open-source-audit skill. We're about to make this repo public.
```

**Expected behavior:** Scans for cloud IDs, tokens, emails, internal URLs, tracked caches. Reports findings by severity.

### production-quality

```
Use the production-quality skill on the files changed in the last commit.
```

**Expected behavior:** Runs lint, code-review, test-coverage, security-scan. Reports weighted score. Scopes to changed files only.

## How to Use

1. Copy this file to your project's `tests/` or `docs/` directory
2. Replace the placeholder file paths and module names with your actual project structure
3. Run each prompt in Claude Code after setting up agents and skills
4. Verify the expected behavior matches what actually happens
5. If something doesn't work as expected, adjust the agent/skill config and re-test

Add new test prompts as you customize agents or create project-specific skills.
