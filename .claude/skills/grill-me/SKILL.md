---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when the user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

# Grill Me

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.

If a question can be answered by exploring the codebase, explore the codebase instead.

## Approach

### 1. Understand the Proposal

Read what the user has shared (plan, design doc, PRD, or verbal description). Identify the core decisions being made and the assumptions behind them.

### 2. Map the Decision Tree

Identify the key decision branches:

- **Scope**: What's in, what's out, and why the line is drawn there
- **Approach**: Why this solution over alternatives
- **Dependencies**: What must be true for this to work
- **Risks**: What could go wrong and what's the mitigation
- **Sequencing**: What order things happen and why

### 3. Walk Each Branch

For each branch, ask the hardest question first. Resolve it before moving to the next. Don't let the user hand-wave -- push for specifics:

- "What happens when X fails?"
- "How do you know Y is true?"
- "What's the simplest version of this that still works?"
- "Who else does this affect?"
- "What would change your mind about this approach?"

### 4. Resolve Dependencies Between Decisions

Some decisions depend on others. When you find a dependency, resolve the upstream decision first. Call this out explicitly: "Before we can decide X, we need to settle Y."

### 5. Converge

When all branches are resolved, summarize the shared understanding: what was decided, what assumptions were validated, and what open items remain (if any).

## Ground Rules

- One question at a time. Don't overwhelm with five questions in a row.
- Push back on vague answers. "It depends" is not an answer -- ask "on what?"
- If the user says "I don't know", that's a finding. Note it and move on.
- Don't suggest solutions. The goal is to stress-test the user's plan, not redesign it.
- Stop when you've walked every branch, not when you run out of questions.
