---
name: fix-flaky-spec
description: Diagnose and fix flaky feature specs by identifying the root cause rather than papering over timing issues. Use when a spec passes sometimes but fails intermittently in CI.
---

# Fix Flaky Spec

Diagnose and properly fix intermittently failing specs. The goal is always to eliminate the root cause — never to mask it with retries, sleeps, or increased timeouts. Principles are framework-neutral; examples use Ruby/RSpec/Capybara with Vue/Vuetify for illustration.

## Anti-patterns (NEVER do these)

These are band-aids, not fixes. They hide the real problem and make the test suite slower and less trustworthy:

- **Adding `sleep`** to wait for something to be ready
- **Retry loops** that re-click or re-find elements hoping it works the second time
- **Increasing timeouts** beyond what Capybara already provides
- **Rescuing and retrying** Selenium errors
- **Adding `wait:` to assertions** that already have sufficient wait time

If you find yourself reaching for any of these, stop and dig deeper into the root cause.

## Step 1: Reproduce and Understand the Failure

Read the failing spec and the full stack trace carefully. Identify:

1. **Which assertion fails** — the exact `expect` or `find` that times out
2. **What action precedes it** — the click, fill, or navigation that should trigger the expected state
3. **The component type** — is it a `v-select`, `v-autocomplete`, `v-combobox`, or plain HTML?

Run the spec a few times locally to understand the failure mode:
```bash
bundle exec rspec path/to/spec.rb:LINE
```

If it passes locally every time, that's a clue — the issue may be timing-sensitive and only manifests under CI load (8 parallel Selenium nodes).

## Step 2: Classify the Root Cause

Flaky specs almost always fall into one of these categories:

### A. Async Data Loading Race Condition
**Symptom**: Overlay/dropdown opens but items aren't there yet.
**Cause**: The component fetches data lazily (on menu open, on search input) rather than eagerly.
**Fix**: Make the component pre-fetch its data before the user interacts with it. Change the Vue component so data is loaded when the tab/page/section becomes active, not when the field is clicked.

Example: A `v-autocomplete` with `@update:menu` that calls `fetchUsers()` only on open. Fix by also calling `fetchUsers()` when the parent tab activates.

### B. Stale Overlay / Overlay Collision
**Symptom**: The test expects an overlay but finds one from a previous interaction, or expects no overlay but one lingers.
**Cause**: Previous `v-select`/`v-autocomplete` overlay didn't fully close before the next interaction.
**Fix**: Ensure overlays are properly dismissed between interactions. Use `page.send_keys(:escape)` and assert the overlay is gone with `have_no_css` before proceeding. The `select_from_overlay` pattern in existing specs handles this — use it or the `VuetifySelectHelpers` module.

### C. Element Not Scrolled Into View
**Symptom**: Click doesn't register, element not interactable.
**Cause**: The element is below the fold or obscured by a sticky header/footer.
**Fix**: Use `page.scroll_to(element)` before clicking. But if you need to add a `sleep` after scrolling, that's a sign the real fix is elsewhere (see category A).

### D. Ambiguous Selectors
**Symptom**: Test clicks the wrong element or finds an unexpected match.
**Cause**: Selector like `.v-btn` or `find('button', text: 'Edit')` matches multiple elements on the page.
**Fix**: Use `data-testid` attributes for reliable element targeting. Add a `data-testid` to the Vue template if one doesn't exist, then use `find("[data-testid='specific-button']")` in the spec.

### E. Time-dependent Logic
**Symptom**: Spec fails around midnight, month boundaries, or DST transitions.
**Cause**: Test relies on `Date.current`, `Time.zone.now`, or relative time calculations.
**Fix**: Use `travel_to` (ActiveSupport) or `Timecop.freeze` to pin time in the test.

### F. Non-deterministic Database State
**Symptom**: Spec fails when run in a different order or with parallel test groups.
**Cause**: Test depends on records created by other tests, or `let!` ordering assumptions.
**Fix**: Make the test self-contained. Each scenario should create exactly the data it needs. Use `Fabricate` to create test records within the spec.

### G. Vue Reactivity / v-model Timing
**Symptom**: Input value doesn't propagate, form validation doesn't trigger.
**Cause**: Setting `input.value` directly bypasses Vue's reactivity. Or `v-model` updates are debounced.
**Fix**: Use the `fill_composer_input` pattern that dispatches both `input` and `change` events via JS. For debounced fields, the fix belongs in the component (reduce/remove debounce when unnecessary) rather than adding sleep in the test.

## Step 3: Fix in the Right Layer

**Prefer fixing the application code** over fixing the test code:

| Root Cause | Fix Location |
|---|---|
| Lazy data loading race | Vue component (eager fetch) |
| Missing `data-testid` | Vue template |
| Debounce too aggressive | Vue component |
| Overlay not closing | Vue component or test helper |
| Time-dependent | Test (freeze time) |
| Ambiguous selector | Test (better selector) |
| Database state | Test (self-contained setup) |

The test should describe *what the user does and sees*. If the test needs special tricks to work, the application probably has a UX issue too.

## Step 4: Verify the Fix

A single passing run proves nothing for a flaky spec. Run the specific scenario at least 10 times:

```bash
for i in $(seq 1 10); do
  echo "=== Run $i ==="
  bundle exec rspec path/to/spec.rb:LINE --format documentation 2>&1 | grep -E '(example|failure)'
  echo
done
```

All 10 must pass. Then run the full spec file to check for regressions:

```bash
bundle exec rspec path/to/spec.rb --format documentation
```

## Step 5: Use Existing Test Helpers

This project has well-built Vuetify test helpers in `spec/support/`. Use them instead of writing ad-hoc overlay/select logic:

- `VuetifySelectHelpers#vuetify3_select(label, value)` — select from `v-select`
- `VuetifySelectHelpers#vuetify3_searchable_select(label, value)` — select from `v-autocomplete`/`v-combobox`
- `VuetifySelectHelpers#vuetify3_multiselect(label, value)` — multi-select
- `VuetifyOverlayHelpers#wait_for_overlay_scrim_to_disappear` — wait for scrim animations
- `VuetifyOverlayHelpers#within_active_dropdown_overlay` — scope assertions to the active overlay

These helpers already handle scrolling, waiting for items, parallel-mode timeouts, and cleanup.

## Common Patterns in This Codebase

From past flaky spec fixes in this project:

- **v-select/v-autocomplete blur**: Use `page.send_keys(:escape)` followed by `page.send_keys(:tab)` to reliably close and blur Vuetify dropdowns (see commit `8a3fc6fa6`).
- **Ambiguous click targets**: Scope clicks to `data-testid` containers instead of matching by text globally (see commit `dca486375`).
- **Scrolling before click**: Use `page.scroll_to(field)` when the element may be off-screen, but address *why* the element needs scrolling — often the test is interacting with too many fields in sequence without the page naturally scrolling.

## Gotchas

- **Declaring victory after one green run**: A flaky spec that passes once proves nothing. Always run the scenario at least 10 times before claiming the fix works (see Step 4).
- **Fixing the test when the application is the real problem**: If the test needs special tricks (sleeps, polling, retries) to work, the application probably has a UX issue too. Fix the Vue component, not the spec.
- **Treating a local pass as evidence**: A spec that passes locally but fails in CI is almost always a race condition that only manifests under parallel load. Don't assume the bug is gone just because your machine is fast enough to hide it.
- **Adding `wait:` to an already-waiting assertion**: Capybara's `expect(page).to have_*` matchers already wait. Adding `wait: 10` masks a deeper issue — the element isn't appearing at all, not appearing slowly.
- **Reaching for `sleep` as a "temporary" workaround**: Temporary sleeps become permanent. If you're tempted to add one, classify the root cause in Step 2 instead.

## Scoring (0-100)

Additive scoring based on methodology quality:

| Criterion | Points |
|-----------|--------|
| Root cause classified into one of the categories in Step 2 | 30 |
| Fix applied in the right layer (app vs. test) per the table in Step 3 | 20 |
| No anti-patterns introduced (no sleeps, retries, inflated timeouts) | 20 |
| Verified with 10+ consecutive green runs of the scenario | 20 |
| Full spec file passes after fix (no regressions) | 10 |

| Score | Interpretation |
|-------|---------------|
| 90-100 | Root cause eliminated -- clean fix in the right layer, verified under load |
| 70-89 | Fix works but methodology gaps (e.g., fewer verification runs, slight layer mismatch) |
| 50-69 | Fix is fragile -- symptom addressed but root cause unclear |
| 0-49 | Anti-pattern applied -- sleep/retry/timeout added without root cause fix |

## Completion

Report directly to the user (as a message, not written to a file):

```
## Flaky Spec Fix Report

### Spec
- <path/to/spec.rb:LINE> -- <one-sentence description of the failure>

### Root Cause
- Category: <A-G from Step 2>
- <one-sentence root cause statement>

### Fix Applied
- <file:line> -- <what was changed and why>
- Layer: <Vue component | Vue template | test helper | spec>

### Verification
- Scenario run 10x: <N pass, M fail>
- Full spec file: <pass/fail>

### Summary
- **Score: X/100** (<points breakdown>)
```

## Anti-Patterns

- **Adding `sleep`**: Hides timing bugs; makes the suite slower and still flaky.
- **Retry loops around clicks or finds**: Masks the real reason the element isn't ready.
- **Inflating Capybara timeouts**: Buys time but doesn't fix the race; CI load will catch up.
- **Rescuing Selenium errors**: Swallows signal that the page is in a broken state.
- **Marking the spec as `skip` or `pending`**: Not a fix — file a ticket and fix the root cause.
