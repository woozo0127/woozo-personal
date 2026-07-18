---
name: rules-install
description: Use this skill when the user wants to install, activate, or apply the Woozo rules feature globally in Codex — including phrases like "install rules", "activate rules", "rules 설치", "rules 활성화", "코딩 룰 적용", "behavioral rules 켜기", or any explicit request to make the rules available in future Codex sessions. This skill manages marked blocks in `~/.codex/AGENTS.md`.
---

# rules install

Install the rules feature into Codex global instructions by copying this plugin's rule files (`rules/development.md`, `rules/thinking.md`, `rules/writing.md`) into managed blocks in `~/.codex/AGENTS.md`.

## When to use

- User asks to install, activate, enable, or apply rules in Codex
- User wants the Woozo rules applied globally for future Codex sessions
- User reports the rules are not being injected and wants to reinstall them

## Owned blocks

This skill manages exactly the blocks between these marker pairs in `~/.codex/AGENTS.md`:

```markdown
<!-- woozo-personal:development-rules:start -->
<!-- woozo-personal:development-rules:end -->
```

```markdown
<!-- woozo-personal:thinking-rules:start -->
<!-- woozo-personal:thinking-rules:end -->
```

```markdown
<!-- woozo-personal:writing-rules:start -->
<!-- woozo-personal:writing-rules:end -->
```

Do not edit unrelated content in `~/.codex/AGENTS.md`.

| Source file | Marker pair | Content header |
|---|---|---|
| `rules/development.md` | `woozo-personal:development-rules` | `# Development Rules` |
| `rules/thinking.md` | `woozo-personal:thinking-rules` | `# Critical Thinking Rules` |
| `rules/writing.md` | `woozo-personal:writing-rules` | `# Writing Rules` |

## Procedure

Apply steps 1–4 for each rule file in the table above.

1. Resolve the source file:
   - First try `rules/<file>` relative to the current repository.
   - If unavailable, locate this plugin root and use its `rules/<file>`.
   - If the source cannot be found, stop and tell the user the plugin files are incomplete.

2. Read `~/.codex/AGENTS.md` as text. Treat a missing file as empty.

3. Build the managed block by copying the full source content verbatim between the owned markers. The block must contain:
   - start marker
   - source content beginning with the content header from the table
   - end marker

4. Inspect the target file:
   - **Both markers exist** -> replace only the content from the start marker through the end marker.
   - **Neither marker exists** -> append the managed block after existing content, preserving existing content verbatim and ensuring one blank line before the block.
   - **Only one marker exists** -> stop, show the marker line found, and ask the user how to repair the partial block.

5. Verify:

```sh
grep -n "woozo-personal:development-rules:start" ~/.codex/AGENTS.md
grep -n "woozo-personal:development-rules:end" ~/.codex/AGENTS.md
grep -n "# Development Rules" ~/.codex/AGENTS.md
grep -n "woozo-personal:thinking-rules:start" ~/.codex/AGENTS.md
grep -n "woozo-personal:thinking-rules:end" ~/.codex/AGENTS.md
grep -n "# Critical Thinking Rules" ~/.codex/AGENTS.md
grep -n "woozo-personal:writing-rules:start" ~/.codex/AGENTS.md
grep -n "woozo-personal:writing-rules:end" ~/.codex/AGENTS.md
grep -n "# Writing Rules" ~/.codex/AGENTS.md
```

6. Inform the user that Codex reads global instructions in new sessions, so they should restart Codex or start a new session for the rules to take effect.

## Constraints

- Preserve all content outside the owned blocks verbatim.
- Do not modify `~/.claude/`, `.claude-plugin/`, or Claude Code settings.
- Do not create symlinks for Codex.
- Do not modify Claude-only plugin features.
