---
name: update
description: Use this skill when the user has updated the Woozo Codex plugin and wants the installed rules re-synced in `~/.codex/AGENTS.md` — including phrases like "update 적용", "rules 최신화", "플러그인 업데이트 반영", or any request to refresh the managed Woozo blocks to the latest rule contents. Rebuilds blocks that already exist and appends blocks for newly shipped rule files; does not perform a first-time install.
---

# update

Re-sync the managed Woozo blocks in `~/.codex/AGENTS.md` with the plugin's latest rule files after a plugin update. Complements `rules-install` (first-time install); this skill only refreshes an existing installation.

Keep in sync with `rules-install` — it defines the source resolution and block format this skill reuses.

## Owned blocks

Same as `rules-install`:

| Source file | Marker pair | Content header |
|---|---|---|
| `rules/development.md` | `woozo-personal:development-rules` | `# Development Rules` |
| `rules/thinking.md` | `woozo-personal:thinking-rules` | `# Critical Thinking Rules` |
| `rules/writing.md` | `woozo-personal:writing-rules` | `# Writing Rules` |

## Procedure

1. Read `~/.codex/AGENTS.md`. If the file is missing or contains no `woozo-personal:` rule markers at all, the rules are not installed — tell the user to run `rules-install` instead and stop.

2. The rules feature is installed. Sync every rule file in the table above:
   - **Both markers exist** → resolve the source file (same order as `rules-install`: `rules/<file>` in the current repository first, then this plugin root) and replace the content between the markers with the latest source verbatim.
   - **Neither marker exists** → the rule file is newly shipped; append a full managed block (start marker, source content, end marker) after existing content, preserving existing content verbatim and ensuring one blank line before the block.
   - **Only one marker exists** → stop, show the marker line found, and ask the user how to repair the partial block.

3. If a `woozo-personal:*-rules` block exists in the file but its source rule file no longer ships with the plugin → leave the block in place and report it to the user (removal is `rules-uninstall`'s job).

4. Verify:

```sh
grep -n "woozo-personal:development-rules:start" ~/.codex/AGENTS.md
grep -n "# Development Rules" ~/.codex/AGENTS.md
grep -n "woozo-personal:thinking-rules:start" ~/.codex/AGENTS.md
grep -n "# Critical Thinking Rules" ~/.codex/AGENTS.md
grep -n "woozo-personal:writing-rules:start" ~/.codex/AGENTS.md
grep -n "# Writing Rules" ~/.codex/AGENTS.md
```

5. Inform the user that new Codex sessions pick up the refreshed instructions; the current session keeps already-loaded ones.

## Constraints

- Preserve all content outside the owned blocks verbatim.
- Do not perform first-time installs (that's `rules-install`) or removals (that's `rules-uninstall`).
- Do not modify `~/.claude/`, `.claude-plugin/`, or Claude Code settings.
- Do not create symlinks for Codex.
