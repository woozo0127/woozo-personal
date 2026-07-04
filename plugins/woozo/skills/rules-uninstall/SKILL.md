---
name: rules-uninstall
description: Use this skill when the user wants to uninstall, deactivate, disable, or remove the Woozo rules feature from Codex — including phrases like "uninstall rules", "deactivate rules", "rules 제거", "rules 비활성화", "코딩 룰 끄기", or "behavioral rules 끄기". This skill removes the managed Woozo blocks from `~/.codex/AGENTS.md`.
---

# rules uninstall

Remove the Woozo rules feature from Codex global instructions by deleting only this plugin's managed blocks from `~/.codex/AGENTS.md`.

## When to use

- User asks to uninstall, deactivate, disable, or remove rules in Codex
- User wants future Codex sessions to stop loading Woozo rules
- User is troubleshooting and wants a clean rules state before reinstalling

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

Do not remove unmarked content.

## Procedure

1. Read `~/.codex/AGENTS.md` as text. If it does not exist, the rules are already uninstalled.

2. For each marker pair (`development-rules`, `thinking-rules`), inspect the owned markers:
   - **Both markers exist** -> remove the start marker, all content between the markers, and the end marker. Preserve all other content verbatim.
   - **Neither marker exists** -> report that this Codex rules block is already absent.
   - **Only one marker exists** -> stop, show the marker line found, and ask the user how to repair the partial block.

3. Verify:

```sh
! grep -q "woozo-personal:development-rules:start" ~/.codex/AGENTS.md
! grep -q "woozo-personal:development-rules:end" ~/.codex/AGENTS.md
! grep -q "woozo-personal:thinking-rules:start" ~/.codex/AGENTS.md
! grep -q "woozo-personal:thinking-rules:end" ~/.codex/AGENTS.md
```

4. Inform the user that removal applies to new Codex sessions. The current session may keep already-loaded instructions.

## Constraints

- Preserve all content outside the owned blocks verbatim.
- Do not modify `~/.claude/`, `.claude-plugin/`, or Claude Code settings.
- Do not remove symlinks under `~/.claude/rules/`.
- Do not modify Claude-only plugin features.
