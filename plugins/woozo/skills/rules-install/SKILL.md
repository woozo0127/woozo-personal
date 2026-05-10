---
name: rules-install
description: Use this skill when the user wants to install, activate, or apply the Woozo rules feature globally in Codex — including phrases like "install rules", "activate rules", "rules 설치", "rules 활성화", "코딩 룰 적용", "behavioral rules 켜기", or any explicit request to make the rules available in future Codex sessions. This skill manages a marked block in `~/.codex/AGENTS.md`.
---

# rules install

Install the rules feature into Codex global instructions by copying this plugin's `rules/development.md` into a managed block in `~/.codex/AGENTS.md`.

## When to use

- User asks to install, activate, enable, or apply rules in Codex
- User wants the Woozo rules applied globally for future Codex sessions
- User reports the rules are not being injected and wants to reinstall them

## Owned block

This skill manages exactly the block between these markers in `~/.codex/AGENTS.md`:

```markdown
<!-- woozo-personal:development-rules:start -->
<!-- woozo-personal:development-rules:end -->
```

Do not edit unrelated content in `~/.codex/AGENTS.md`.

## Procedure

1. Resolve the source file:
   - First try `rules/development.md` relative to the current repository.
   - If unavailable, locate this plugin root and use its `rules/development.md`.
   - If the source cannot be found, stop and tell the user the plugin files are incomplete.

2. Read `~/.codex/AGENTS.md` as text. Treat a missing file as empty.

3. Build the managed block by copying the full `rules/development.md` content verbatim between the owned markers. The block must contain:
   - start marker
   - source content beginning with `# Development Rules`
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
```

6. Inform the user that Codex reads global instructions in new sessions, so they should restart Codex or start a new session for the rules to take effect.

## Constraints

- Preserve all content outside the owned block verbatim.
- Do not modify `~/.claude/`, `.claude-plugin/`, or Claude Code settings.
- Do not create symlinks for Codex.
- Do not modify Claude-only plugin features.
