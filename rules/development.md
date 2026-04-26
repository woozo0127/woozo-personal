# Development Rules

Behavioral guide for agents writing, modifying, or reviewing code. Applies to every coding task regardless of language or stack.

## 1. Clarify before coding

**Rule:** Ask before writing code when the request is ambiguous. State assumptions explicitly.

- Do: surface the 1-2 most load-bearing ambiguities first
- Don't: code from assumptions and announce "here's what I built"
- Why: code built on wrong assumptions gets thrown away whole

## 2. Read context first

**Rule:** Inspect existing patterns and conventions before changing anything. New patterns require explicit justification.

- Do: read adjacent files and similar modules first
- Do: follow existing naming, structure, and library choices
- Don't: introduce new files, patterns, or libraries unprompted

## 3. Small, scoped changes

**Rule:** One thing at a time. No unrelated refactoring.

- Do: change only what the request covers
- Don't: touch unrelated code you noticed in passing
- Don't: bundle cleanup into a bug-fix PR
- Why: preserves the unit of review, rollback, and bisect

## 4. YAGNI — no overengineering

**Rule:** Build only what is requested. No speculative extension points, options, or abstractions.

- Do: ship the simplest implementation that solves the actual problem
- Don't: add "might-need-later" abstractions, optional params, or feature flags
- Don't: add error handling, fallbacks, or validation for impossible scenarios
- Don't: extract abstractions before the same pattern repeats 3+ times
- Why: unused code costs deletion effort plus comprehension overhead

## 5. Debug to root cause

**Rule:** Don't paper over symptoms. Form a hypothesis, verify it, then fix.

- Do: reproduce → hypothesize → verify → fix, in that order
- Do: only patch when you can answer "why does this symptom occur"
- Don't: swallow errors with empty try/catch
- Don't: edit test expectations to make a failing test pass
- Don't: bypass hooks with `--no-verify` to ship faster

## 6. Verify before claiming done

**Rule:** No "fixed", "passing", or "complete" claims without evidence the code runs.

- Do: run tests, type-checks, builds, and the actual feature
- Do: for UI changes, exercise the flow in a browser or simulator
- Don't: end with "should work" guesses
- Don't: assume types passing means the feature works

## 7. Boundaries and interfaces

**Rule:** Drawing boundaries well is the root of all design. Each unit has one purpose, depends in one direction, and exposes an explicit interface.

**Heuristics for boundaries:**

- **Things that change together belong together** (cohesion). Same change reason → same unit.
- **Things that change for different reasons get separated** (SRP). Different change reason, frequency, concern, or owner → boundary.
- **Direction:** stable → unstable dependency is wrong. Domain → UI is wrong. UI → domain is right.
- **Abstraction cost vs coupling cost** is a real trade-off. The wrong abstraction is worse than duplication.

**Do:**
- Each unit answers: what does it do, how do I use it, what does it depend on
- Keep the interface stable while internals change
- Mark public/private explicitly — export only what callers need
- One file, one module, one hook = one responsibility

**Don't:**
- Mega files, multi-purpose classes, multi-purpose hooks
- Circular dependencies
- Speculative abstraction (no abstracting until the pattern repeats 3+ times)
- Leaking implementation details through the interface

**Boundary smell signals:**
- One file gets edited for many unrelated reasons → split candidate
- "Where should this function live" is hard to decide → responsibility unclear
- A change breaks something seemingly unrelated → coupling too high
- Import graph has a cycle → redesign now, not later

## 8. Naming and readability

**Rule:** Names carry intent. Comments explain why, not what.

- Do: use meaningful variable and function names (no 1-letter or cryptic abbreviations)
- Do: comment only on non-obvious constraints, subtle invariants, or workaround reasons
- Don't: write WHAT-comments (`// increment counter`)
- Don't: reference the current task or PR in comments (`// added for issue #123`)

## 9. Reversibility and blast radius

**Rule:** Confirm with the user before destructive or shared-state changes.

- Do: take local, reversible actions freely (edits, tests, local builds)
- Don't: run `rm -rf`, `git reset --hard`, force-push, or DB drops without explicit confirmation
- Don't: auto-modify shared infrastructure, CI configs, or open/close PRs unprompted
- Don't: delete unfamiliar files, branches, or lock files — investigate first

## 10. Surface trade-offs

**Rule:** Technical decisions get alternatives and reasoning, not silent choices.

- Do: present 2-3 approaches plus a recommendation with reasoning
- Do: state the trade-off in one line (perf vs readability, simplicity vs flexibility)
- Don't: pick silently and start coding
- Don't: justify a choice with "best practice" alone — say *why* it fits this case

## Methodology Catalog

Named methodologies the agent can reference when picking an approach. Rules 1-10 cover *how to behave*; the catalog covers *which methodology to invoke*.

| Name | One-liner | When |
|------|-----------|------|
| **TDD** (Test-Driven Development) | failing test → minimal code → refactor | new features, bug fixes (write the reproducer first) |
| **Refactoring** (Fowler) | preserve behavior, improve structure in small safe steps | standalone code-improvement work, never mixed with feature changes |
| **SOLID** | OOP 5 principles (SRP/OCP/LSP/ISP/DIP) | class, module, hook design. For functional FE, apply the spirit (SRP and DIP especially) |
| **DDD (core)** | domain model, ubiquitous language, bounded context | when business logic is genuinely complex. FE usually needs view-model level only |
| **YAGNI** | don't build until it's needed | every task — directly tied to rule 4 |
| **KISS** | the simplest thing that works | every task |
| **DRY** | remove duplication — only when the pattern repeats 3+ times | abstraction decisions. Wrong abstraction beats minor duplication |

**Application priority:**

1. YAGNI / KISS — always
2. TDD — for verifiable logic (utils, hooks, pure functions, business rules)
3. Refactoring — as standalone code-improvement work
4. SOLID / DDD / DRY — consult when making design decisions

**Conflict resolution:**

- DRY vs YAGNI → YAGNI wins. No premature abstraction.
- TDD vs throwaway prototype → situational, but production code defaults to TDD.
- DDD vs simple CRUD → simple CRUD doesn't need a domain layer. Don't build one.
