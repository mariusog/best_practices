---
name: ui-design
description: Review and improve UI consistency, visual design, and styling. Check for spacing consistency, component patterns, and design system adherence. Use when the user asks to review UI, fix styling issues, or improve visual consistency.
---

# UI Design Skill

Review and improve user interface consistency, visual design, and styling patterns. Language- and framework-neutral — adapt the specific selectors and tools to your project's stack.

## Scope

Changed frontend files in the current branch:
```bash
# Adapt the extensions to your stack (e.g., *.vue, *.svelte, *.tsx, *.jsx, *.css, *.scss)
git diff --name-only origin/main...HEAD -- '*.tsx' '*.jsx' '*.css' '*.scss' '*.vue' '*.svelte'
```
Also read the **parent layout/page component** that wires them together for full page context.

## Step 1: Read All Changed Files + Design System

Read everything before changing anything:
1. All changed UI files (full content, not just diffs)
2. The parent/layout component that orchestrates them
3. Project styleguide if one exists (check `docs/ux/STYLEGUIDE.md` or similar)
4. Shared component library for established patterns

## Step 2: Cross-Component Consistency

This is the highest-impact step. **Sibling components** (rendered side-by-side or in the same layout zone) must handle the same concepts identically.

For each concept below, compare across ALL changed files:

| Concept | What to grep | What must match across siblings |
|---------|-------------|-------------------------------|
| State/status colors | Color functions, status mappings, severity helpers | Same resolution method AND same fallback value |
| Number formatting | `toFixed`, format functions, display helpers | Same formatter, same decimal handling |
| Section headings | `<h2>`, `<h3>`, heading components | Same typography classes at the same hierarchy level |
| Status indicators | Badges, chips, tags, status labels | Same size, variant for same semantic type |
| Tooltips | `title=`, tooltip components | Same pattern and placement style |
| Empty states | Conditional renders for missing data | Same pattern (message, icon, or dedicated component) |

**How to check**: If 2+ sibling files handle the same concept differently, that's a bug. Converge on the most canonical version.

### Common offenders
- **Reinvented helpers**: Local color/status functions duplicated across components with different fallback values
- **Raw formatting**: `value.toFixed(1)` in one place vs `formatValue(value)` helper in another
- **Inconsistent status styling**: One file uses a pill badge, its sibling uses inline text for the same status concept

## Step 3: Spacing & Layout Consistency

Check spacing follows consistent patterns. If the project has a spacing scale, verify adherence. If not, check for internal consistency:

### Common Spacing Issues
- Inconsistent margins/padding between similar elements
- Hardcoded pixel values instead of spacing tokens/variables
- Missing responsive adjustments for smaller screens
- Inconsistent gap values in flex/grid layouts
- Mixing units (px, rem, em) without a clear convention

### What to look for
- Sibling components at the same level should use the same padding/margin
- Lists of similar items should have uniform spacing
- Section separators should be consistent across pages

## Step 4: Typography Hierarchy

Verify typography follows a consistent scale:

### Common Typography Issues
- Inconsistent heading levels across similar pages
- Missing font weight differentiation between headings and body
- Caption/secondary text using different sizes in different components
- Conflicting typography classes on the same element

### What to check
- Page titles, section titles, card titles should each use a consistent style
- Body text and labels should be uniform
- If a typography scale exists (CSS variables, Tailwind config, theme file), verify components use it

## Step 5: Color & Theme Consistency

Check colors use a consistent system:

### Color Usage
- **DO**: Use semantic color tokens (CSS variables, theme constants, design tokens)
- **DON'T**: Scatter raw hex/rgb values across components
- **Status colors**: Use consistent semantic mapping (success, warning, error, info)
- **Backgrounds and text**: Use semantic names, not raw values

### Common Color Issues
- Hardcoded hex values instead of CSS variables or theme tokens
- Inconsistent opacity/alpha values for similar effects
- Status colors varying between components
- Light/dark mode incompatibilities from hardcoded values

## Step 6: Component Pattern Consistency

### Common Pattern Issues
- **Inline styles duplicating CSS classes**: `style="display: flex; gap: 8px"` when a utility class or component exists
- **Inconsistent wrapper components**: Different border, padding, background for same-level containers
- **Mixed approaches**: Some components using CSS modules, others scoped styles, others global classes — without a clear convention

### Inline styles
Flag `style="..."` in templates where shared CSS classes or utility classes exist. Dynamic computed styles (data-driven widths, colors from state) are acceptable.

### Custom CSS duplicating framework utilities
If the project uses a utility framework (Tailwind, Vuetify, Bootstrap, etc.), check `<style>` blocks for CSS that could be replaced with utility classes. Only flag when the custom CSS is on elements that could take the framework's classes directly.

## Step 7: Fix Issues

Priority order:
1. **Cross-component inconsistencies** (Step 2) — highest visual impact, things users notice as "off"
2. **Design system violations** (Steps 3–5) — prevents future drift
3. **Redundant custom CSS / inline styles** (Step 6) — less code = fewer inconsistencies later

For each fix:
1. Update to use the consistent/canonical pattern
2. Extract shared values to design tokens, CSS variables, or shared constants
3. Prefer shared components or utility classes over duplicated markup/styles

## Step 8: Verify Changes

1. Run the **Lint** and **Format** commands from the CLAUDE.md Tooling table — must pass with 0 errors
2. If applicable, run **Type check** from the CLAUDE.md Tooling table — must pass
3. Verify dark mode / theme compatibility if the project supports it

## Gotchas

- **Flagging intentional variation as inconsistency**: Not all differences between components are bugs. A compact sidebar widget and a full-page detail view may legitimately use different spacing. Only flag inconsistencies between components at the same hierarchy level serving the same purpose.
- **Replacing dynamic styles with static classes**: Inline styles driven by runtime data (computed widths, colors from state, conditional positioning) are correct. Only flag inline styles that duplicate static CSS classes.
- **Fixing one side of a pair**: When converging two inconsistent components, verify you chose the canonical pattern (the one used by more components, or the one documented in the styleguide). Converging to the wrong version doubles the fix work later.
- **Ignoring empty states**: Empty/loading states are often styled differently from their populated versions. Check that skeleton screens and placeholders match the real component's dimensions and elevation.

## Scoring (0-100)

Start at 100. Deduct points for each **unresolved** issue (after fixes in Step 7):

| Category | Deduction per issue |
|----------|---------------------|
| Cross-component inconsistency (same concept, different implementation) | -10 |
| Design system violation (spacing, typography, color) | -5 |
| Redundant inline style / custom CSS duplicating shared pattern | -2 |
| Minor style nit (could go either way) | -1 |

| Score | Interpretation |
|-------|---------------|
| 90-100 | Consistent — siblings match, design system followed |
| 70-89 | Mostly consistent — a few cross-component mismatches |
| 50-69 | Inconsistent — multiple visible discrepancies across components |
| 0-49 | Needs significant work — no consistent patterns across siblings |

## Completion

For each fix, state **what was inconsistent between which files** and what it was converged to. Don't list per-file property checks that found nothing. Focus on what a user would actually see as "off" on the page.

Report:
- UI files reviewed
- Cross-component inconsistencies fixed
- Spacing issues fixed
- Typography issues fixed
- Color/theme issues fixed
- Custom CSS replaced with shared patterns/utilities
- **Score: X/100** (deductions itemized by category)
