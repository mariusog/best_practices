# Tasks

**Owner**: lead-agent (exclusively). Other agents read this file but do not write to it.

Each agent has a separate plan file with detailed checklists:
- [TASKS-core.md](TASKS-core.md) -- core-agent tasks
- [TASKS-feature.md](TASKS-feature.md) -- feature-agent tasks
- [TASKS-qa.md](TASKS-qa.md) -- qa-agent tasks

## Format

<!-- TASKS.md Schema
     ==============
     Lead-agent maintains this file. All other agents READ ONLY.

     Task IDs:   T1, T2, T3, ... (sequential, never reuse IDs)
     Agents:     lead-agent, core-agent, feature-agent, qa-agent, researcher-agent
     Statuses:   open, in-progress, done, blocked, deferred
     Depends on: comma-separated task IDs (e.g. "T2, T3") or "-" for none

     Workflow:
       1. Lead creates tasks here and writes detailed checklists in per-agent plan files
       2. Agents read this file for assignments, then work from their own plan file
       3. Agents report results in their plan file (TASKS-core.md, etc.)
       4. Lead validates results and updates status/result here

     A task is NOT done until lead validates and moves it to the Done section.
-->

Each task has: **ID**, **Agent**, **Title**, **Status**, **Depends on**, and (when done) a **Result**.

**Statuses**: `open` | `in-progress` | `done` | `blocked` | `deferred`

**Depends on**: Other task IDs that must be `done` before this task can start. Agents must check dependencies before beginning work.

## Open

| ID | Agent | Title | Status | Depends on |
|----|-------|-------|--------|------------|
| T1 | qa-agent | Set up test infrastructure | open | - |
| T2 | core-agent | Implement core algorithms | open | - |
| T3 | feature-agent | Implement business logic | open | T2 |

## In Progress

| ID | Agent | Title | Status | Depends on | Notes |
|----|-------|-------|--------|------------|-------|
<!-- Move tasks here when an agent begins work. Add notes for blockers or context. -->

## Done

| ID | Agent | Title | Result |
|----|-------|-------|--------|
<!-- Result format: <what changed> | <metric before> -> <metric after> | tests: <pass count> pass -->
<!-- Example: -->
<!-- | T1 | qa-agent | Set up test infrastructure | Created conftest.py with 5 fixtures | n/a -> 12 tests pass | tests: 12 pass | -->

## Blocked / Deferred

| ID | Agent | Title | Status | Blocked by | Notes |
|----|-------|-------|--------|------------|-------|
<!-- Tasks that cannot proceed. Include the blocker (task ID or description) and when it was escalated. -->
<!-- Example: -->
<!-- | T3 | feature-agent | Implement business logic | blocked | T2 | Waiting on core algorithms (escalated 2025-03-19) | -->

## Constants Requested

Agents tag `NEEDS CONSTANT: NAME = value (reason)` in their plan files. Lead-agent tracks and resolves them here.

| Requested by | Constant | Value | Reason | Status |
|--------------|----------|-------|--------|--------|
<!-- Example: -->
<!-- | core-agent | MAX_RETRIES | 3 | Connection retry limit for data fetcher | added | -->
