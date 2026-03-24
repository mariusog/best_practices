---
name: skill-creator
description: Create new skills, modify and improve existing skills. Use when users want to create a skill from scratch, edit an existing skill, test a skill with example prompts, or iterate on a skill to improve its quality. Also use when the user says "turn this into a skill" or asks to capture a workflow as a reusable skill.
---

# Skill Creator

A skill for creating new skills and iteratively improving them.

The process:

1. Capture what the skill should do
2. Write the SKILL.md
3. Test it with a few realistic prompts
4. Iterate based on results

Your job is to figure out where the user is in this process and help them move forward. Maybe they want to create something from scratch — help them clarify intent, write a draft, test it. Maybe they already have a draft — jump straight to testing and iteration. Maybe they just want to vibe — do that instead.

Be flexible. Follow the user's lead.

---

## Communicating with the user

Pay attention to the user's technical level. Some users are experienced developers; others are new to this. Default to plain language. Terms like "evaluation" are fine; for "JSON" or "assertion", look for cues that the user knows what those mean before using them without a brief explanation.

---

## Step 1: Capture Intent

Start by understanding what the user wants. The current conversation may already contain a workflow they want to capture (e.g., "turn this into a skill"). If so, extract what you can from conversation history first — the tools used, the sequence of steps, corrections the user made, input/output formats observed — then confirm and fill gaps.

Key questions:

1. **What should this skill enable Claude to do?**
2. **When should it trigger?** (what user phrases, contexts, or task types)
3. **What's the expected output?** (format, structure, artifacts)
4. **Are there edge cases or constraints?** (input formats, dependencies, things to avoid)

Proactively ask about edge cases, example files, success criteria, and dependencies. Get this ironed out before writing.

---

## Step 2: Write the SKILL.md

### Skill Writing Guide

#### Anatomy of a Skill

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/    - Executable code for deterministic/repetitive tasks
    ├── references/ - Docs loaded into context as needed
    └── assets/     - Files used in output (templates, icons, fonts)
```

A skill is just a directory with a SKILL.md file. Everything else is optional.

#### Progressive Disclosure

Skills use a three-level loading system:

1. **Metadata** (name + description) — Always in context (~100 words). This is how Claude decides whether to use the skill.
2. **SKILL.md body** — Loaded when the skill triggers. Keep under 500 lines.
3. **Bundled resources** — Read on demand. Unlimited size. Scripts can execute without being loaded into context.

If the SKILL.md is approaching 500 lines, push detail into reference files and add clear pointers about when to read them.

**Domain organization** — When a skill supports multiple frameworks or variants:
```
cloud-deploy/
├── SKILL.md (workflow + selection logic)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```
Claude reads only the relevant reference file based on context.

#### The Description Field

The description is the primary triggering mechanism. It determines whether Claude activates the skill. All "when to use" information goes here, not in the body.

Claude currently tends to **undertrigger** — it won't use a skill even when it would help. To counter this, make descriptions a little "pushy". Include both what the skill does AND specific contexts for when to use it.

Instead of:
> "How to build a simple fast dashboard to display internal data."

Write:
> "How to build a simple fast dashboard to display internal data. Use this skill whenever the user mentions dashboards, data visualization, internal metrics, or wants to display any kind of data, even if they don't explicitly ask for a 'dashboard.'"

#### Frontmatter Fields

- **name** (required): Skill identifier, matches the directory name.
- **description** (required): When to trigger and what it does. See advice above.
- **compatibility** (optional, rarely needed): Required tools or dependencies.

#### Writing Style

Explain the **why** behind instructions. Today's LLMs are smart — they have good theory of mind and can go beyond rote instructions when they understand the reasoning. If you find yourself writing ALWAYS or NEVER in all caps, or using rigid structures, that's a yellow flag. Reframe and explain the reasoning so the model understands why the thing matters. That's more effective than heavy-handed imperatives.

Use the imperative form for instructions. Include examples where they help — they're one of the most effective ways to communicate expected behavior.

**Defining output formats:**
```markdown
## Report structure
Use this template:
# [Title]
## Executive summary
## Key findings
## Recommendations
```

**Including examples:**
```markdown
## Commit message format
**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

#### Principle of Lack of Surprise

Skills must not contain malware, exploit code, or content that could compromise security. A skill's contents should not surprise the user if described. Don't create misleading skills or skills designed for unauthorized access, data exfiltration, or other malicious activities. Roleplay or creative skills are fine.

#### Gotchas Section

Every skill should include a `## Gotchas` section documenting real failure patterns observed in practice. This is often the highest-signal content in a skill — add entries when you discover things the skill should handle but doesn't, or common mistakes the model makes when following the instructions.

#### Scoring and Completion (for executable skills)

Skills that evaluate or audit code should produce a **Score: X/100** so results are comparable across runs and across skills. The `production-quality` orchestrator aggregates these scores.

Two scoring patterns work well:

- **Deduction-based** (start at 100, subtract per issue): Good for audit skills like `code-review`, `security-scan`, `lint`. Use severity-based deductions (Critical -20, High -10, Medium -5, Low -2).
- **Additive rubric** (sum points across criteria): Good for process skills like `tdd-cycle`, `refactor`, `test-coverage`. Define 5-10 criteria that total 100.

Every executable skill should also have a `## Completion` section defining what to report when done — files changed, issues found, and the score with breakdown. This is how the agent knows what "done" looks like.

Reference skills that teach patterns (e.g., `caching-strategies`, `data-pipeline`) don't need scoring — they provide knowledge, not evaluation. But consider adding a checklist of patterns to verify.

---

## Step 3: Test It

After writing the skill draft, create 2-3 realistic test prompts — the kind of thing a real user would actually say. Share them with the user for review before running them.

For example: "Here are a few test prompts I'd like to try. Do these look right, or should we adjust?"

Then run each prompt with the skill active and examine the results. Look at both the final output and the process — did the model follow the skill's instructions? Did it waste time on unproductive steps? Did it miss edge cases?

If the skill produces file outputs, check those files. If it produces conversation-style output, read through the full response.

---

## Step 4: Iterate

This is where skills get good. You've run the tests, seen the results, and gotten feedback from the user. Now improve.

### How to think about improvements

1. **Generalize from the feedback.** You and the user are iterating on a few examples to move fast, but the skill will be used across many different prompts. If the skill only works for those exact examples, it's useless. Rather than adding fiddly, overfitting changes or oppressively restrictive MUSTs, try different approaches — different metaphors, different patterns. It's cheap to experiment.

2. **Keep the prompt lean.** Remove things that aren't pulling their weight. Read through the test transcripts, not just the final outputs — if the skill is making the model waste time on unproductive steps, try removing those parts and see what happens.

3. **Explain the why.** When feedback reveals a problem, don't just patch the symptom. Understand what the user actually needs, and transmit that understanding into the instructions. The model will handle novel situations better when it understands the reasoning behind the rules.

4. **Look for repeated work across test cases.** If every test run independently wrote a similar helper script or took the same multi-step approach, that's a signal the skill should bundle that script. Write it once, put it in `scripts/`, and reference it from the skill.

### The iteration loop

1. Apply your improvements to the skill
2. Rerun the test prompts
3. Compare with previous results — did it get better?
4. Ask the user for feedback
5. Repeat until the user is happy, feedback is empty, or you're not making meaningful progress

Start with a draft, look at it with fresh eyes, then improve. Take your time on revisions — thinking time is not the bottleneck.

---

## Updating an Existing Skill

The user might ask you to update a skill rather than create one from scratch. In this case:

- **Preserve the original name.** Note the skill's directory name and `name` frontmatter field — use them unchanged.
- **Read the existing skill carefully** before making changes. Understand its current intent and structure.
- **Follow the same test-iterate loop** — test the modified skill against realistic prompts and verify the changes work as intended.

---

## Quick Reference

```
1. Capture intent    → What, when, output format, edge cases
2. Write SKILL.md    → Frontmatter + instructions + gotchas
3. Test              → 2-3 realistic prompts, examine results
4. Iterate           → Generalize, stay lean, explain why
```

## Gotchas

- **Skill descriptions that are too narrow will under-trigger**: Err on the side of being slightly pushy about when to activate. A skill that never triggers is worse than one that occasionally triggers when not needed.
- **Test prompts that are too simple won't trigger skill invocation**: Claude handles trivial tasks without consulting skills. Use realistic, moderately complex prompts that would genuinely benefit from the skill's guidance.
- **Iterating on the skill body without re-testing leads to drift**: Always re-run test prompts after significant changes. The skill may look better on paper but perform worse in practice if you skip validation.
