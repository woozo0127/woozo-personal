---
name: install
description: Use this skill when the user wants to install, activate, or apply the `rules` plugin globally — including phrases like "install rules", "activate rules", "rules 설치", "rules 활성화", "코딩 룰 적용", "behavioral rules 켜기", or any explicit request to make the rules available in every Claude Code session. The skill creates symlinks at `~/.claude/rules/woozo/development.md` and `~/.claude/rules/woozo/communication.md` pointing at this plugin's source files, so the user's existing `~/.claude/rules/*.md` auto-load mechanism picks them up at every session start. Does not modify `settings.json` or `CLAUDE.md`.
---

# rules install

Install the `rules` plugin into the user's global rules directory by creating symlinks to the plugin's source files. The user's environment auto-loads `~/.claude/rules/*.md` as global instructions, so symlinks are enough — no SessionStart hook needed.

## When to use

- User asks to install / activate / enable rules
- User wants the rules applied globally for the first time
- User reports the rules aren't being injected and wants to (re)install

## Owned files

This skill manages exactly these targets under `~/.claude/rules/woozo/`. The `woozo/` subdirectory is this plugin's namespace — never touch entries outside it (e.g. `~/.claude/rules/commit.md`).

| Source (truth) | Target (symlink) |
|---|---|
| `${CLAUDE_PLUGIN_ROOT}/rules/development.md` | `~/.claude/rules/woozo/development.md` |
| `${CLAUDE_PLUGIN_ROOT}/rules/communication.md` | `~/.claude/rules/woozo/communication.md` |

Source files are the truth — never edit through the symlink; edit the source.

## Procedure

Run the procedure below **once per owned file**. The flow is identical; only the file name differs.

1. **Resolve the source absolute path:**
   - First try `${CLAUDE_PLUGIN_ROOT}/rules/<file>.md`. If `${CLAUDE_PLUGIN_ROOT}` expands and the file exists, use that.
   - Fallback: glob `~/.claude/plugins/cache/woozo-personal/rules/*/rules/<file>.md` and pick the lexicographically largest path (latest version directory).
   - If neither resolves, abort and ask the user to run `/plugin update` for the `rules@woozo-personal` plugin.
   - Resolve to a true absolute path (`realpath` or `python3 -c "import os,sys;print(os.path.realpath(sys.argv[1]))"`) before using as the symlink target — relative paths break when the symlink is read from a different cwd.

2. **Ensure the target directory exists:** `mkdir -p ~/.claude/rules/woozo`.

3. **Inspect `~/.claude/rules/woozo/<file>.md`:**
   - **Does not exist** → `ln -s <abs-source> ~/.claude/rules/woozo/<file>.md`. Done.
   - **Symlink pointing to the resolved source** → already installed. Tell the user, skip (no-op).
   - **Symlink pointing elsewhere** → show the user the current target via `readlink`, confirm replacement. On yes: `rm` the symlink, then `ln -s` the new one.
   - **Regular file** → likely a user-edited copy from a previous fork. Show its `ls -la` and first few lines, confirm replacement. On yes: rename to `<file>.md.bak` (don't delete), then `ln -s` the new one.

4. **Verify each symlink:**
   ```sh
   readlink ~/.claude/rules/woozo/development.md
   readlink ~/.claude/rules/woozo/communication.md
   test -f ~/.claude/rules/woozo/development.md && head -3 ~/.claude/rules/woozo/development.md
   test -f ~/.claude/rules/woozo/communication.md && head -3 ~/.claude/rules/woozo/communication.md
   ```
   Each `readlink` should match the resolved source path. Heads should start with `# Development Rules` and `# Communication Rules` respectively.

5. **Inform the user:** installed; takes effect on the next session start (existing sessions don't re-read global rules).

## Constraints

- **Never overwrite without confirming** when the existing entry is a regular file or a foreign symlink — it may be the user's intentional customization.
- **Never edit the source files through the symlink** to apply per-user tweaks. If the user wants per-machine edits, suggest forking: replace symlink with a copy (`cp -L`), then they own the file (and lose plugin-update sync).
- **Touch only the owned files** under `~/.claude/rules/woozo/`. Do not modify `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, or sibling entries in `~/.claude/rules/` (e.g. `commit.md`).
- **Do not register a SessionStart hook.** The whole point of this skill is to use the file-system auto-load mechanism.
