---
name: preferred-workflow
description: Use when the user hands you a feature idea, PRD, or GitHub issue number and expects the full pipeline from idea to merged PR — or says "let's do this the normal way", "use my preferred workflow", or "ship this end-to-end". Orchestrates grill-me → write-a-prd → prd-to-issues → (optional) product-review → implement → project-architecture → production-quality → green CI → resolve review comments → ping.
---

# Preferred Workflow

The standard end-to-end skill for taking a feature from idea to a merged PR. Seven sequential phases, plus one optional review step between Phases 1 and 2; the agent drives while the user intervenes only at decision points (PRD review, follow-up triage, final approval).

## Trigger Phrases

- "let's do this the normal way"
- "use my preferred workflow"
- "ship this end-to-end"
- Handing the agent a PRD/idea and expecting the full pipeline

## When NOT to Use

- Bug fixes that don't warrant a PRD (just open a PR).
- Refactors with no behavior change (just open a PR).
- One-line edits, doc tweaks, dep bumps.

## Respect the Project's GitHub Templates

Every phase that creates a GitHub artifact must use the **project's own template** when one exists — the generic structures in `/write-a-prd`, `/prd-to-issues`, and `/pr-workflow` are fallbacks for repos that ship none.

- **Issues**: if the repo defines `.github/ISSUE_TEMPLATE/*.md|*.yml` (or a `config.yml` chooser), file against the matching template — honor its headings, required fields, and default labels.
- **PRs**: if the repo defines `.github/pull_request_template.md` / `.github/PULL_REQUEST_TEMPLATE.md` (or `.github/PULL_REQUEST_TEMPLATE/*.md`), fill that structure, not a generic one.
- **Caveat**: `gh pr create --body/--body-file` (and `gh issue create --body`) **bypass** the template. When you pass a body non-interactively, build it from the template file and fill every section, so template-driven and CLI-driven artifacts match.

## Skill Resolution — Local-First, Fallback Second

Each phase invokes a skill (`/grill-me`, `/write-a-prd`, `/prd-to-issues`, `/product-review`, `/project-architecture`, `/production-quality`, `/pr-workflow`). Not every repo has all of them installed, and some repos ship richer, stack-tuned versions.

1. **Prefer the local project skill** whenever one matches the phase's intent — a repo-specific skill (e.g. a Rails-tuned `production-quality` that knows the project's test DBs, migrations, and i18n) beats the generic version.
2. **If no local skill matches, fall back to this repo's copy** rather than skipping the phase: read `.claude/skills/<skill>/SKILL.md` and apply its guidance by hand.
3. **Never silently skip a phase because its skill is missing.** Fall back and do it manually; if you applied a phase "by spirit" because no skill existed, say so in the Phase 7 ping.
4. If a repo repeatedly lacks the workflow skills, consider filing a follow-up to install them locally (porting the building-block skills verbatim keeps them easy to re-sync; author the orchestrator locally so it can carry repo-specific glue).

## Local Test Scope — Don't Duplicate CI

Every repo in this pipeline already requires green CI (Phase 5) before a PR ships — CI runs the full suite as a required check regardless of what ran locally. Re-running the entire local suite on every iteration duplicates that guarantee and pays real wall-clock/token cost for a signal Phase 5 already provides.

- **Scope local test runs to the changed code.** After an edit, run the specific test file(s) that mirror the changed source file(s) per the repo's own test-location convention (e.g. `app/foo/bar.rb` ↔ `spec/foo/bar_spec.rb`), plus any test that directly exercises a changed shared surface (a shared client, concern, base class, or controller other specs call into).
- **Run the full local suite only when it earns its cost**: the change touches something cross-cutting (a shared concern, base class, config, or fixture many specs depend on), or a scoped run left ambiguous signal. "About to open the PR" is *not* by itself a reason to re-run everything — that's what Phase 5 is for.
- **CI (Phase 5) is the authoritative full-suite gate.** Once scoped tests are green and lint/architecture/review pass, open or push to the PR and let CI confirm the rest.
- This doesn't relax "zero tolerance for test failures" — it only changes which tests run locally versus which CI is trusted to run.

## Phase 1 — Plan

Goal: convert an idea into independently-grabbable GitHub issues.

1. **Stress-test the idea** with `/grill-me`. Resolve scope, dependencies, risks, sequencing before writing anything. A fuzzy PRD becomes fuzzy issues.
2. **Write the PRD** with `/write-a-prd`. The PRD becomes a GitHub issue (the skill submits it).
3. **Break into implementation issues** with `/prd-to-issues`. Each issue is a vertical tracer-bullet slice grabbable independently.
4. **File against the repo's issue templates** when they exist (see Respect the Project's GitHub Templates) — match headings, required fields, and labels rather than free-form bodies.

Exit criteria: a GitHub issue exists for every slice of work, each with enough context for a fresh agent to pick up cold.

## Phase 1.5 — Product Review (optional, before any code)

Goal: have a product owner — not a code reviewer — challenge the PRD and issues while changing course is still free.

`/grill-me` stress-tests the idea *the user brought*. This phase asks a different question: is that the right thing to build, and is the proposed surface one a portfolio owner would defend? Run it with the repo's product-manager agent where one exists, or the `/product-review` skill otherwise.

**Run it when** the change adds a new user-facing surface (an API, a tool in a catalog, a CLI command, a page); when it touches a surface other people or agents already navigate; when the design has a genuine fork you resolved by picking rather than by proving; or when you can't name who calls the thing and in what moment.

**Skip it when** the issue is a bug fix, a refactor with no behaviour change, or a mechanical change with one obvious shape. This phase costs a full agent run — spend it where the surface is the risk, not the implementation.

Give the reviewer the settled decisions explicitly and ask it to judge whether they were the *right* calls, not to relitigate them. Ask it directly: what is missing, what is over-built, and does this cohere with the surfaces that already exist?

Triage its findings the same way as Phases 3–4 — fix now, or file a follow-up — with one addition: a finding that invalidates a design decision goes back to the user as a decision, not into a commit. Update the PRD and issues in place so they describe what will actually be built; a PRD that no longer matches the plan is worse than no PRD.

Exit criteria: every finding is applied, filed, or explicitly declined with a reason; the PRD and issues reflect any design change the review produced.

## Phase 2 — Implement One Issue

Goal: solve exactly one GitHub issue, end-to-end, in a single PR.

1. Confirm the issue number with the user if ambiguous.
2. Create a branch following the repo's git conventions (`<agent>/<issue#>-<short-description>`).
3. Solve everything the issue asks for. The issue is the contract; do not split scope. Run tests scoped to the changed code as you go (see Local Test Scope) — not the full suite.
4. Open the PR via `/pr-workflow` (or `gh pr create`), linking the issue for auto-close on merge. Fill the repo's PR template if one exists.

Exit criteria: PR is open, references the issue, diff covers every acceptance criterion.

## Phase 3 — Architecture Audit

Goal: surface architectural friction before the code ships.

1. Run `/project-architecture` on the PR's diff.
2. For every finding:
   - **Fix in this PR** only if it's a trivial in-file cleanup on code this PR already touches.
   - **New GitHub follow-up issue** otherwise (out-of-diff files, >2-line changes, scope expansion).
3. Default leans toward issue-not-inline. Tight PRs review faster.

Exit criteria: every finding is committed in the PR or filed as a follow-up issue. Nothing silently dropped.

## Phase 4 — Production-Quality Pass

Goal: lint, refactor, coverage, security, code-review, docs — all green.

1. Run `/production-quality` on the PR's diff.
2. Same follow-up rule as Phase 3 (trivial in-file → commit; anything bigger → issue).
3. Push cleanup commits. Verify each with tests scoped to what the commit touched, not a full-suite rerun.

Exit criteria: `/production-quality` reports clean (or all remaining findings have follow-up issues filed); no unaddressed lint/test/security warnings on changed files.

## Phase 5 — Wait for Green CI

Goal: every required CI check on the PR is green before handoff. CI failures are never follow-ups. This is the full-suite gate — see Local Test Scope for why local runs stay scoped instead of pre-empting this phase.

Polling options (pick one):

- **`/goal`** (preferred) — hand the agent a goal like "PR #N is green and the user has been pinged"; fits because Phases 5–7 are a "keep checking until condition holds, then act" loop.
- **`/loop`** — fixed-interval check (e.g. `/loop 5m gh pr checks <PR#>`).
- **`ScheduleWakeup`** — self-paced waits (default 1200 s+ idle ticks, 270 s when actively watching a run mid-flight).

If CI fails: read logs (`gh run view <run-id> --log-failed`), diagnose, fix in this PR, push, wait again — repeat until green. If CI is flaky (passes on retry without code change): note in a PR comment, proceed once green, file a separate issue only if the flake is reproducible.

## Phase 6 — Resolve Code Review Comments

Goal: address review feedback before handing off. Once CI is green, the PR's review comments are the last gate — never ping with unaddressed comments.

1. **Fetch all review feedback** on the PR, not just one surface:
   - Inline review threads: `gh api repos/<owner>/<repo>/pulls/<PR#>/comments`
   - PR-level reviews: `gh api repos/<owner>/<repo>/pulls/<PR#>/reviews`
   - Issue-style comments: `gh pr view <PR#> --json comments`
   - Include automated reviewers (Codex, Copilot) — they routinely catch real P1/P2 correctness bugs, not just style.
2. **Triage every comment** — nothing is silently ignored:
   - **Fix in this PR** if it's a valid correctness/quality issue on code this PR touches (the default for P1/P2 findings). Write a regression test where applicable, commit, push.
   - **Reply + file a follow-up issue** if it's out-of-scope or a larger refactor — same follow-up rule as Phases 3–4.
   - **Reply + decline** with a brief rationale if it's a false positive or you disagree.
3. Post a short reply on each thread (or a single PR comment referencing the fix commit) so every comment is visibly resolved, fixed, or answered.
4. **Any fix push re-opens Phase 5** — wait for green CI again before proceeding. Loop Phases 5↔6 until CI is green AND every comment is resolved.

Exit criteria: every review comment is fixed, deferred-with-issue, or answered; CI is green on the final commit.

## Phase 7 — Ping the User

Post a single concise summary once Phases 1–6 are complete:

- PR link.
- One-line summary of what shipped.
- Count and links of any follow-up issues filed in Phases 3–4 and 6.
- Confirmation that CI is green and all review comments are resolved.

Then **stop**. Merging is the user's call.

## Gotchas

- **Don't bundle issues into one PR.** If the issue is too small or too big, surface that to the user instead of silently re-scoping.
- **Don't skip `/grill-me` even when the idea seems clear.** It's the cheapest way to catch a scoping mistake.
- **Phase 1.5 is not a second `/grill-me`.** `/grill-me` interrogates the user about the idea they brought; the product review challenges whether that idea is the right one and whether its surface coheres with what already exists. Feed it the settled decisions and ask it to judge them — a reviewer that relitigates resolved questions produces noise, and one given no decisions produces generic advice.
- **A Phase 1.5 finding that changes the design goes to the user, not into a commit.** The whole point of running it before Phase 2 is that course changes are still free. Take the decision back to the user, then update the PRD and issues so they describe what will actually be built.
- **Respect the repo's issue/PR templates.** File issues and open PRs against the project's GitHub templates — match their sections, required fields, and labels. The generic structures in the skills are fallbacks. Remember `gh ... --body` bypasses templates, so replicate their sections when passing a body.
- **Follow-up rule is "issue unless trivial"**: trivial = (a) touches a file already in the PR diff AND (b) ≤ 2-line change. Anything else → file an issue.
- **CI failures are NEVER follow-ups.** If CI is red, the PR is not done.
- **Don't skip a phase because its skill is missing** — fall back and apply it by hand.
- **Don't ping with unresolved review comments.** Automated reviewers (Codex/Copilot) often flag genuine bugs — treat their P1/P2 findings like any other; fix or explicitly answer them.
- **Don't merge for the user.** Stop at the ping step.
- **One concurrent PR through this pipeline at a time** unless the user explicitly says otherwise. Parallel PRs multiply context cost without speeding up the human review bottleneck.
- **Don't re-run the full local suite as a habit.** Scope test runs to the changed code. Phase 5's CI run is the full-suite gate — running the whole suite locally too, "just to be safe," is double work for the same signal, not double safety. This applies throughout Phases 2–4, not just once before opening the PR.
