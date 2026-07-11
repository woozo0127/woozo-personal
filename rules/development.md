# Development Rules

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.
- If the design is complex, present it - don't decide silently.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. Surface Conflicts, Don't Average Them

**Pick one. Explain why. Flag the other for cleanup.**

When two patterns contradict:

- Pick the more recent or more tested. Don't blend.
- State why you picked it - don't choose silently.
- Flag the loser for cleanup. Don't "fix" it as a side effect.
- If you can't tell which is canonical, ask.

Two contradictory patterns merged into one usually breaks both.

## 6. Read Before You Write

**Understand surrounding code before adding to it.**

Before writing new code:

- Read the file's exports and immediate callers.
- Check shared utilities - don't reinvent what already exists.
- If you can't explain why code is structured a certain way, ask.

"Looks orthogonal" is the famous last words of an unintended regression.

## 7. Tests Verify Intent, Not Just Behavior

**A test should fail when intent breaks, not just when implementation changes.**

- Encode the WHY, not just the WHAT.
- A test that can't fail when business logic changes is worthless.
- If a test mirrors implementation line-by-line, it's a copy, not a test.

Ask yourself: "If the requirement changed, would this test fail?" If no, rewrite it.

## 8. Checkpoint After Every Significant Step

**Know where you are before taking the next step.**

After each meaningful change:

- Summarize what was done, what's verified, what's left.
- Don't continue from a state you can't describe back.
- If you lose track, stop and restate.

The test: You can answer "what's done and what's next?" without scrolling.

## 9. Match the Codebase, Even If You Disagree

**Conformance over taste. Surface disagreements, don't fork silently.**

When working in an existing codebase:

- Match existing style, naming, and patterns.
- Don't introduce a "better" convention as a side effect.
- If a convention seems genuinely harmful, raise it - don't quietly do it your way.

The test: A reader can't tell which lines you wrote vs. the original author.

## 10. Fail Loud

**Surface skips, errors, and uncertainty - don't bury them.**

When reporting status:

- "Completed" is wrong if anything was skipped silently.
- "Tests pass" is wrong if any were skipped or stubbed.
- "Works" is wrong if you didn't actually run it.

Default to surfacing uncertainty. Loud failures are cheaper than silent ones.

## 11. TDD: Contract First

**Settle the contract before the test; the test before the code.**

- Define the public contract first - signatures, input/output types, error behavior, invariants - before writing any test.
- Write the test against that contract, not against an implementation you've already pictured.
- Drive the red-green-refactor loop from the contract; let it be the spec the tests encode.
- If the contract is still fuzzy, settle it before testing - don't let tests freeze an accidental shape.

Ask yourself: "Could someone else implement this from the contract alone?" If not, it isn't settled yet.

## 12. Design Before Build

**Agree on what to build before building it.**

For any non-trivial feature or behavior change:

- Understand purpose, constraints, and success criteria before writing code. If unclear, ask - one focused question at a time.
- If the request spans multiple independent pieces, propose a decomposition before refining details of any one piece.
- Propose 2-3 approaches with trade-offs and a recommendation. Lead with the recommendation - don't present a menu without an opinion.
- Present the design scaled to its complexity (a few sentences for simple work) and get agreement before implementing.
- Trivial changes (typos, obvious one-liners) skip the ceremony - but still state what you're about to do.

The test: The user never sees an implementation they wouldn't have approved as a design.

## 13. Debug by Root Cause

**No fixes before the root cause is understood. Symptom patches are failures.**

When something breaks (bug, failing test, unexpected behavior):

- Read the full error and stack trace first. Reproduce reliably. Check what changed recently (git diff, deps, config). Can't reproduce → gather more evidence, don't guess.
- In multi-component paths, instrument the boundaries to locate WHICH layer fails before theorizing about why.
- Trace the bad value to its origin. Fix at the source, not where it surfaced.
- One explicit hypothesis at a time ("X causes this because Y"), tested with the smallest possible change. Never stack a second fix on an unverified first.
- Reproduce with a failing test before fixing (rule 4), then verify nothing else broke.
- After 3 failed fix attempts, stop - the problem is likely the design, not the spot. Present the pattern to the user instead of attempting fix #4.

Red flags meaning "return to investigation": "quick fix now, investigate later", "just try changing X", "it's probably X", bundling multiple changes into one attempt.
