# Development Rules

Behavioral guide for agents writing, modifying, or reviewing code. Applies to every coding task regardless of language or stack.

## Methodologies

**Non-trivial work** = adding or modifying code that contains branching, state, or computation logic. Plain text/config edits, single-line edits, and docs changes do NOT count as non-trivial.

Before starting non-trivial work, pick a methodology from the table below and **announce** it. Items with explicit triggers apply automatically when the trigger fires. When you don't invoke an item with an ambiguous trigger (DDD especially), **state why you didn't**.

| Name | One-liner | Trigger | Announce format |
|------|-----------|---------|-----------------|
| **Refactoring** (Fowler) | preserve behavior, improve structure in small safe steps | only when the user explicitly says "refactor / cleanup / restructure". Don't start on your own judgment (see Rule 3). | "Refactor: [step granularity]" |
| **DDD (core)** | domain model, ubiquitous language, bounded context | when business logic is genuinely complex. NOT for simple CRUD. | "Domain layer introduced: [reason]" |

**Conflict resolution:**

- Abstraction urge vs leave it → leave it (see Rule 6's 3+ rule).
- Domain layer vs simple CRUD → simple CRUD doesn't need a domain layer. Don't build one.

## Behavioral Rules

### 1. Clarify before coding

**Rule:** Ask before writing code when the request is ambiguous. State assumptions explicitly.

- Do: surface the 1-2 most load-bearing ambiguities first
- Don't: code from assumptions and announce "here's what I built"
- Why: code built on wrong assumptions gets thrown away whole

### 2. Read context first

**Rule:** Inspect existing patterns and conventions before changing anything. New patterns require explicit justification.

- Do: read adjacent files and similar modules first
- Do: follow existing naming, structure, and library choices
- Don't: introduce new files, patterns, or libraries unprompted

### 3. Small, scoped changes

**Rule:** One thing at a time. No unrelated refactoring.

- Do: change only what the request covers
- Do: surface unrelated issues you noticed as a separate note — don't fold them into the current change
- Don't: touch unrelated code you noticed in passing
- Don't: bundle cleanup into a bug-fix PR
- Why: preserves the unit of review, rollback, and bisect

### 4. Debug to root cause

**Rule:** Don't paper over symptoms. Form a hypothesis, verify it, then fix.

- Do: reproduce → hypothesize → verify → fix, in that order
- Do: only patch when you can answer "why does this symptom occur"
- Do: when the root cause is outside the current change scope, surface it and ask the user how to proceed (consistent with Rule 3)
- Don't: swallow errors with empty try/catch
- Don't: edit test expectations to make a failing test pass
- Don't: bypass hooks with `--no-verify` to ship faster

### 5. Verify before claiming done

**Rule:** No "fixed", "passing", or "complete" claims without evidence the code runs.

- Do: run tests, type-checks, builds, and the actual feature
- Do: for UI changes, exercise the flow in a browser or simulator
- Do: when test infrastructure is absent, exercise the actual code path (manual run, dry-run, sample input) and report what you observed
- Do: state the result of each verification step — not only what passed, but also what couldn't run and why
- Don't: end with "should work" guesses
- Don't: assume types passing means the feature works

### 6. Boundaries and interfaces

**Rule:** Drawing boundaries well is the root of all design. Each unit has one purpose, depends in one direction, and exposes an explicit interface.

**Heuristics for boundaries:**

- **Things that change together belong together** (cohesion). Same change reason → same unit.
- **Things that change for different reasons get separated** (SRP). Different change reason, frequency, concern, or owner → boundary.
- **Direction:** stable → unstable dependency is wrong. Domain → UI is wrong. UI → Domain is right. (DIP)
- **Substitutability (LSP):** every implementation of the same interface/protocol must behave identically from the caller's perspective. Same signature ≠ same meaning — divergent thrown exceptions, side effects, or pre/post-conditions are LSP violations.
- **Abstraction cost vs coupling cost** is a real trade-off. The wrong abstraction is worse than duplication.
- **3+ rule:** don't abstract until the same pattern repeats 3+ times.

**Do:**
- Each unit answers: what does it do, how do I use it, what does it depend on
- Keep the interface stable while internals change (OCP)
- Mark public/private explicitly — export only what callers need (ISP)
- One file, one module, one hook = one responsibility (SRP)

**Don't:**
- Mega files, multi-purpose classes, multi-purpose hooks
- Circular dependencies
- Speculative abstraction
- Leak implementation details through the interface
- Let different implementations of the same interface behave differently in meaning (LSP violation)

**Boundary smell signals:**
- One file gets edited for many unrelated reasons → split candidate
- "Where should this function live" is hard to decide → responsibility unclear
- A change breaks something seemingly unrelated → coupling too high
- Swapping in a different implementation of the same interface breaks the caller → LSP violation
- Import graph has a cycle → redesign now, not later

### 7. Surface trade-offs

**Rule:** Technical decisions get alternatives and reasoning, not silent choices.

- Do: present 2-3 approaches plus a recommendation with reasoning
- Do: state the trade-off in one line (perf vs readability, simplicity vs flexibility)
- Don't: pick silently and start coding
- Don't: justify a choice with "best practice" alone — say *why* it fits this case
