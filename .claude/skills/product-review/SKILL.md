---
name: product-review
description: "Review features for product consistency, alignment with strategy, and user value. Use when starting new features, completing work, or deciding what to build next."
---

# Product Review Skill

Perform a product-focused review ensuring consistency, strategic alignment, and user value across the application.

## When to Use

- Before starting a new feature (validate alignment)
- After completing significant work (consistency check)
- When deciding what to work on next (prioritization)
- When features seem inconsistent (alignment review)

## Review Checklist

### 1. Feature Alignment

Check that the feature aligns with product goals:

**Core Product Value**
- Does this support the product's core value proposition?
- Does it provide actionable value to the target users?
- Is it accessible to the right user tier (if tiered access exists)?

**Strategic Fit**
- Is this on the product roadmap? (Check roadmap/task docs for priorities)
- Does it support the business model?
- Will it drive user engagement or retention?

### 2. Consistency Review

Check for consistency across the application:

**Terminology**

Every project should maintain a terminology table. If one doesn't exist, create one during this review. Check for:
- Same concepts using different names in different parts of the app
- Abbreviations used inconsistently
- Domain terms that could confuse new users

**Metrics Consistency**
- Are calculations consistent across features?
- Do similar displays use the same number formatting?
- Are color codes used consistently (green=good, red=bad)?

**UI Patterns**
- Does navigation follow established patterns?
- Are cards, tables, and lists styled consistently?
- Do actions (buttons, links) behave predictably?

### 3. User Value Assessment

Evaluate the user impact:

**Problem Solved**
- What user problem does this address?
- How frequent is this problem?
- How painful is it without this feature?

**User Journey**
- Where does this fit in the user workflow?
- Is it discoverable when needed?
- Does it integrate with related features?

**Success Metrics**
- How will we know this is successful?
- What user behavior indicates value?

### 4. Implementation Quality

From a product perspective:

**Edge Cases**
- What happens with no data (new user, empty state)?
- What happens with invalid input?
- Are error messages user-friendly?

**Performance**
- Does it load fast enough for user expectations?
- Is there appropriate loading feedback?

**Accessibility**
- Can all users access this feature?
- Are there any blockers for mobile users?
- Are keyboard interactions supported where needed?

### 5. Documentation Alignment

Verify documentation matches implementation:

**Check These**
- Feature documentation (README, docs/, etc.)
- Any public-facing descriptions (landing page, help text)
- API documentation (if applicable)

**Alignment Checklist**
- [ ] All documented features are actually implemented
- [ ] No undocumented features that should be documented
- [ ] Terminology is consistent between docs and UI
- [ ] Access tiers (if applicable) are correctly described

## Prioritization Framework

When deciding what to work on next:

### P0 - Critical
- Fixes to broken core functionality
- Security issues affecting users
- Data accuracy problems

### P1 - High
- Features on the current roadmap
- High-impact user requests
- Improvements to core workflows

### P2 - Medium
- Quality of life improvements
- Performance optimizations
- Minor feature enhancements

### P3 - Low
- Nice-to-have polish
- Future considerations
- Experimental features

## Gotchas

- **Flagging terminology differences that are correct**: Different parts of an app may legitimately use different terms for different concepts that seem similar. Only flag terminology as inconsistent when the same concept uses different names, not when different concepts happen to sound similar.
- **Reviewing in isolation**: A feature that seems inconsistent in isolation may be following a deliberate pattern established elsewhere. Check at least 2-3 existing features before declaring something inconsistent.
- **Over-prioritizing alignment over shipping**: Consistency is important but shouldn't block shipping a working feature. Flag inconsistencies as follow-up work if the feature itself is sound.
- **Ignoring empty states and error paths**: Product reviews often focus on the happy path. Empty states, error messages, and edge cases are where users form negative impressions — always check these.

## Scoring (0-100)

Evaluate product quality across five dimensions. Award up to 20 points each:

| Dimension | 0-5 (Poor) | 6-10 (Needs work) | 11-15 (Good) | 16-20 (Excellent) |
|-----------|-----------|-------------------|--------------|-------------------|
| **Strategic alignment** | No clear connection to product goals | Loosely related | Supports roadmap | Directly advances core value prop |
| **Terminology consistency** | Multiple conflicts across features | Some inconsistencies | Mostly consistent | Fully consistent with established terms |
| **User value** | Unclear who benefits | Value exists but indirect | Clear value for target users | High-impact, frequently encountered need |
| **Edge case handling** | No empty states or error handling | Some coverage | Most cases handled | All states graceful, user-friendly |
| **Documentation alignment** | Docs contradict implementation | Docs outdated | Docs mostly accurate | Docs fully reflect current state |

| Score | Interpretation |
|-------|---------------|
| 90-100 | Ship-ready — aligned, consistent, valuable |
| 70-89 | Good — minor alignment or consistency issues |
| 50-69 | Needs work — notable gaps in consistency or user value |
| 0-49 | Not ready — fundamental alignment or consistency problems |

## Completion

Report:

1. **Alignment Status**: Does this fit product strategy?
2. **Consistency Issues**: What needs to be aligned?
3. **User Value**: Is the value proposition clear?
4. **Priority**: What priority should this have?
5. **Next Steps**: What actions are recommended?
6. **Score: X/100** (breakdown: alignment Y/20, terminology Y/20, user value Y/20, edge cases Y/20, docs Y/20)

## Related Documentation

- `CLAUDE.md` — Project conventions and architecture
- `TASKS.md` — Current priorities and task assignments
- `docs/` — Feature documentation and design decisions
