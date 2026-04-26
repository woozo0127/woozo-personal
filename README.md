# woozo-personal

Personal Claude Code plugin that injects development rules into every session.

## What it provides

- **`rules/development.md`** — behavioral guide for coding tasks: clarify before coding, read context first, small scoped changes, YAGNI, debug to root cause, verify before claiming done, boundaries and interfaces, naming, blast-radius awareness, surface trade-offs, plus a methodology catalog (TDD, Refactoring, SOLID, DDD, YAGNI, KISS, DRY).
- **`hooks/hooks.json`** — `SessionStart` hook that prints the rule file so Claude Code loads it as session context.

## Install

```bash
/plugin marketplace add woozo0127/woozo-personal
/plugin install woozo-personal@woozo-personal
```
