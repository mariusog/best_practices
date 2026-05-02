---
name: improve-codebase-architecture
description: Surface deepening opportunities in an existing codebase -- refactors that turn shallow modules into deep ones for testability and AI-navigability. Use when the user wants to find architectural friction, consolidate tightly-coupled modules, deepen shallow modules, or make a codebase more navigable. Adapted from mattpocock/skills (https://github.com/mattpocock/skills/tree/main/skills/engineering/improve-codebase-architecture).
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** -- refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

This skill is the *exploration-first* counterpart to `project-architecture`. Where `project-architecture` answers "where should this code go?" for new work, this skill walks an existing codebase looking for friction and proposes consolidations that earn their keep.

## Glossary

Use these terms exactly in every suggestion. Consistent language is the point -- don't drift into "component," "service," "API," or "boundary." Full definitions in [LANGUAGE.md](LANGUAGE.md).

- **Module** -- anything with an interface and an implementation (function, class, package, slice).
- **Interface** -- everything a caller must know to use the module: types, invariants, error modes, ordering, config. Not just the type signature.
- **Implementation** -- the code inside.
- **Depth** -- leverage at the interface: a lot of behaviour behind a small interface. **Deep** = high leverage. **Shallow** = interface nearly as complex as the implementation.
- **Seam** -- where an interface lives; a place behaviour can be altered without editing in place. (Use this, not "boundary.")
- **Adapter** -- a concrete thing satisfying an interface at a seam.
- **Leverage** -- what callers get from depth.
- **Locality** -- what maintainers get from depth: change, bugs, knowledge concentrated in one place.

Key principles (full list in [LANGUAGE.md](LANGUAGE.md)):

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

This skill is *informed* by the project's domain model. If the project has a `CONTEXT.md` or domain glossary, read it first -- domain language gives names to good seams. If there are ADRs (architectural decision records), read those for the area you're touching so you don't re-litigate decided questions.

## Step 1: Explore

Read the project's domain glossary (if any) and ADRs in the area you're touching first.

Then walk the codebase. For broad exploration, use the Agent tool with `subagent_type=Explore`. Don't follow rigid heuristics -- explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** -- interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

Spend no more than 10-15 minutes on exploration. The friction you encounter IS the signal -- you're not building a complete map. If you haven't found friction after reading 10-15 files, the codebase may already be well-structured. Report that as a finding.

## Step 2: Present Candidates

Present a numbered list of deepening opportunities, ranked by impact (most friction first). For each candidate:

- **Files** -- which files/modules are involved
- **Problem** -- why the current architecture is causing friction (point to symptoms: shallow interface, scattered locality, leaky seam, untestable shape)
- **Solution** -- plain-English description of what would change
- **Benefits** -- explained in terms of leverage (what callers gain) and locality (what maintainers gain), and how tests would improve

**Use the project's domain vocabulary for the domain, and [LANGUAGE.md](LANGUAGE.md) vocabulary for the architecture.** If `CONTEXT.md` defines "Order," talk about "the Order intake module" -- not "the FooBarHandler," and not "the Order service."

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly (e.g. *"contradicts ADR-0007 -- but worth reopening because..."*). Don't list every theoretical refactor an ADR forbids.

Do NOT propose interfaces yet. Ask the user: "Which of these would you like to explore?"

## Step 3: Grilling Loop

Once the user picks a candidate, drop into a grilling conversation. Walk the design tree with them -- constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive. The `grill-me` skill is a useful companion here for stress-testing the proposed deepening before committing to it.

Side effects happen inline as decisions crystallize:

- **Naming a deepened module after a concept not in the domain glossary?** Add the term to `CONTEXT.md` (or the project's domain glossary). Create the file lazily if it doesn't exist.
- **Sharpening a fuzzy term during the conversation?** Update the domain glossary right there.
- **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: *"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"* Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing -- skip ephemeral reasons ("not worth it right now") and self-evident ones.
- **Want to explore alternative interfaces for the deepened module?** See [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md).

## Step 4: Validate the Deepening (Optional)

Before the user commits to implementation, sanity-check the proposed deepening:

- **Deletion test**: would deleting the new module concentrate complexity, or just rename a pass-through?
- **Two-adapter test**: does the proposed seam have two real adapters (e.g., Postgres + in-memory), or just one hypothetical one? If only one, the seam is speculative -- defer it.
- **Test surface**: can the proposed interface express every behaviour you currently care about? If you'd still need to "reach past" it in a test, the shape is wrong.
- **Migration path**: can callers be moved over incrementally, with existing tests passing at each step? A deepening that requires a flag-day rewrite is usually too big.

## Step 5: Track the Refactor (Optional)

If the user wants to track the work, capture it:

- A small refactor: hand off to the `refactor` skill.
- A larger one with multiple steps: write a PRD with `write-a-prd`, then turn it into a plan or issues with `prd-to-plan` or `prd-to-issues`.

## Dependency Categories (when designing the seam)

Borrowed from `project-architecture` -- when you reach Step 3 and need to decide where the seam lives, classify the module's dependencies:

1. **In-process** -- pure computation, in-memory state, no I/O. Always deepenable: just merge and test directly.
2. **Local-substitutable** -- dependencies with local stand-ins (PGLite for Postgres, in-memory filesystem). Deepenable if the substitute exists.
3. **Remote but Owned (Ports & Adapters)** -- your own services across a network. Define a port at the module boundary. The deep module owns logic; transport is injected. Tests use an in-memory adapter.
4. **True External (Mock)** -- third-party services you don't control (Stripe, Twilio). Mock at the boundary; deepened module takes the dependency as an injected port.

## Testing Strategy

Core principle: **replace, don't layer.**

- Old unit tests on shallow modules are waste once boundary tests exist -- delete them.
- Write new tests at the deepened module's interface boundary.
- Tests assert on observable outcomes through the public interface, not internal state.
- Tests should survive internal refactors -- they describe behaviour, not implementation.

## Scoring (0-100)

Additive rubric for an exploration session -- start at 0, earn points for each criterion met:

| Criterion | Points |
|-----------|--------|
| Candidates use the [LANGUAGE.md](LANGUAGE.md) glossary consistently (no "service," "boundary," etc.) | 15 |
| Each candidate names files, identifies the friction, and explains benefits in leverage + locality | 20 |
| At least one candidate passes the deletion test (deleting it would concentrate, not move, complexity) | 15 |
| Candidates use the project's domain vocabulary (CONTEXT.md / glossary) where applicable | 10 |
| ADR conflicts are flagged (or absent because none exist) | 10 |
| User picks a candidate; grilling loop walks the design tree branch-by-branch | 15 |
| Two-adapter test applied to any proposed seam | 10 |
| A migration path is sketched (incremental, tests stay green) | 5 |

| Score | Interpretation |
|-------|---------------|
| 90-100 | Strong session -- candidates are concrete, vocabulary is consistent, deepening is validated |
| 70-89  | Good -- minor drift in vocabulary or thin migration plan |
| 50-69  | Mixed -- candidates are vague, deletion test not applied, or grilling skipped |
| 0-49   | Weak -- candidates renamed without consolidating, or proposed seams have no second adapter |

## Completion

Report:

```
## Architecture Deepening: <area>

- **Candidates surfaced**: <N>
- **Candidate chosen**: <one-line description, or "none -- exploration only">
- **Deepening shape**: <interface sketch in 1-2 sentences>
- **Tests replaced / added**: <list>
- **ADRs touched**: <list, or "none">
- **Score: X/100**
```

## Gotchas

- **Drifting into "component" / "service" / "boundary"**: the whole point of the [LANGUAGE.md](LANGUAGE.md) glossary is shared vocabulary. If you catch yourself writing "service," replace it with "module" and check whether the term is hiding a fuzzy idea.
- **Proposing a seam with one adapter**: a single-implementation interface adds friction without leverage. Wait for the second real adapter (production + test fake counts; production + hypothetical doesn't).
- **Renaming a pass-through and calling it deepening**: if the deletion test says "complexity just moves," you renamed the problem. Look for a place where deletion would *concentrate* complexity instead.
- **Ignoring ADRs and re-litigating decisions**: if an ADR explicitly rejected a deepening, surface it only when the original reasoning no longer holds. "I forgot to read the ADRs" is not a good reason.
- **Deepening stable, working code**: code that works, is tested, and rarely changes doesn't need architectural improvement regardless of how it looks. Focus on areas with active friction.
- **Replacing all tests in one PR**: a deepening that requires rewriting every test in one go is too big. Migrate callers and tests incrementally.

## Related Skills

| Need | Skill |
|------|-------|
| Choose where new code goes (greenfield) | `project-architecture` |
| Stress-test the proposed deepening | `grill-me` |
| Capture the refactor as a plan | `write-a-prd` -> `prd-to-plan` / `prd-to-issues` |
| Execute the refactor | `refactor` |
| Verify quality after the refactor | `code-review`, `test-coverage` |
