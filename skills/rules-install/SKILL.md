---
name: rules-install
description: Use this skill when the user wants to install, activate, or apply the rules feature globally — including phrases like "install rules", "activate rules", "rules 설치", "rules 활성화", "코딩 룰 적용", "behavioral rules 켜기", or any explicit request to make the rules available in every Claude Code session. The skill creates symlinks under `~/.claude/rules/woozo/` (`development.md`, `thinking.md`) pointing at this plugin's source files, so the user's existing `~/.claude/rules/*.md` auto-load mechanism picks them up at every session start. Does not modify `settings.json` or `CLAUDE.md`.
---

# rules install

Install the rules feature into the user's global rules directory by creating symlinks to the plugin's source files. The user's environment auto-loads `~/.claude/rules/*.md` as global instructions, so symlinks are enough — no SessionStart hook needed.

## When to use

- User asks to install / activate / enable rules
- User wants the rules applied globally for the first time
- User reports the rules aren't being injected and wants to (re)install

## Owned files

This skill manages exactly these targets under `~/.claude/rules/woozo/`. The `woozo/` subdirectory is this plugin's namespace — never touch entries outside it (e.g. `~/.claude/rules/commit.md`).

| Source (truth) | Target (symlink) |
|---|---|
| `${CLAUDE_PLUGIN_ROOT}/rules/development.md` | `~/.claude/rules/woozo/development.md` |
| `${CLAUDE_PLUGIN_ROOT}/rules/thinking.md` | `~/.claude/rules/woozo/thinking.md` |

Source files are the truth — never edit through the symlink; edit the source.

## Procedure

0. **Clean up legacy `communication.md`:** earlier versions of this plugin shipped a separate `communication.md` rule and installed it at `~/.claude/rules/woozo/communication.md`. It is no longer owned. Inspect that path:
   - **Does not exist** → skip.
   - **Symlink pointing into this plugin's cache** (target starts with `~/.claude/plugins/cache/woozo-personal/woozo/`) → `rm` it without prompting.
   - **Symlink pointing elsewhere** → show the user the current target via `readlink`, confirm before `rm`.
   - **Regular file** → user-edited copy. Show its `ls -la` and first few lines, confirm strongly. Offer to rename to `communication.md.bak` instead of deleting; only `rm` outright if the user explicitly declines the backup.

1. **Resolve the source absolute paths** — for each rule file (`development.md`, `thinking.md`):
   - First try `${CLAUDE_PLUGIN_ROOT}/rules/<file>`. If `${CLAUDE_PLUGIN_ROOT}` expands and the file exists, use that.
   - Fallback: glob `~/.claude/plugins/cache/woozo-personal/woozo/*/rules/<file>` and pick the lexicographically largest path (latest version directory).
   - If neither resolves, abort and ask the user to run `/plugin update` for the `woozo@woozo-personal` plugin.
   - Resolve to a true absolute path (`realpath` or `python3 -c "import os,sys;print(os.path.realpath(sys.argv[1]))"`) before using as the symlink target — relative paths break when the symlink is read from a different cwd.

2. **Ensure the target directory exists:** `mkdir -p ~/.claude/rules/woozo`.

3. **For each rule file, inspect `~/.claude/rules/woozo/<file>`:**
   - **Does not exist** → `ln -s <abs-source> ~/.claude/rules/woozo/<file>`. Done.
   - **Symlink pointing to the resolved source** → already installed. Tell the user, skip (no-op).
   - **Symlink pointing elsewhere** → show the user the current target via `readlink`, confirm replacement. On yes: `rm` the symlink, then `ln -s` the new one.
   - **Regular file** → likely a user-edited copy from a previous fork. Show its `ls -la` and first few lines, confirm replacement. On yes: rename to `<file>.bak` (don't delete), then `ln -s` the new one.

4. **Verify the symlinks:**
   ```sh
   readlink ~/.claude/rules/woozo/development.md
   readlink ~/.claude/rules/woozo/thinking.md
   test -f ~/.claude/rules/woozo/development.md && head -3 ~/.claude/rules/woozo/development.md
   test -f ~/.claude/rules/woozo/thinking.md && head -3 ~/.claude/rules/woozo/thinking.md
   ```
   Each `readlink` should match its resolved source path. The heads should start with `# Development Rules` and `# Critical Thinking Rules` respectively.

5. **Inform the user:** installed; takes effect on the next session start (existing sessions don't re-read global rules).

## Constraints

- **Never overwrite without confirming** when the existing entry is a regular file or a foreign symlink — it may be the user's intentional customization.
- **Never edit the source files through the symlink** to apply per-user tweaks. If the user wants per-machine edits, suggest forking: replace symlink with a copy (`cp -L`), then they own the file (and lose plugin-update sync).
- **Touch only the owned files** under `~/.claude/rules/woozo/`. Do not modify `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, or sibling entries in `~/.claude/rules/` (e.g. `commit.md`).
- **Do not register a SessionStart hook.** The whole point of this skill is to use the file-system auto-load mechanism.
