# Communication Rules

Guide for how the agent communicates with the user. Applies to user-facing output: text answers, code references, and any path or location the user might click, copy, or look up.

## 1. Absolute paths

**Rule:** Always write file paths as absolute paths in user-facing output.

- Do: write `/Users/woojo/workspace/foo/bar.ts:42` (full absolute path, optional `:line`)
- Don't: use `./foo/bar.ts`, `foo/bar.ts`, or `~/workspace/foo/bar.ts`
- Why: the user clicks or copies paths to open them immediately. Cwd-dependent or shell-expanded forms break when the working context shifts.
