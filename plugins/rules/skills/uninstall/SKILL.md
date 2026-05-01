---
name: uninstall
description: Use this skill when the user wants to uninstall, deactivate, disable, or remove the `rules` plugin — including phrases like "uninstall rules", "deactivate rules", "rules 제거", "rules 비활성화", "코딩 룰 끄기", "behavioral rules 끄기". The skill removes `~/.claude/rules/woozo/development.md` and `~/.claude/rules/woozo/communication.md` symlinks created by the install skill, and prunes the empty `woozo/` directory. Does not modify `settings.json` or `CLAUDE.md`.
---

# rules uninstall

Remove the `rules` plugin's symlinks from the user's global rules directory.

## When to use

- User asks to uninstall / deactivate / disable rules
- User wants to stop the rules from being injected globally
- User is troubleshooting and wants a clean slate before reinstalling

## Owned files

This skill manages exactly these targets under `~/.claude/rules/woozo/`. The `woozo/` subdirectory is this plugin's namespace — never touch entries outside it (e.g. `~/.claude/rules/commit.md`).

- `~/.claude/rules/woozo/development.md`
- `~/.claude/rules/woozo/communication.md`

## Procedure

1. **For each owned file, inspect `~/.claude/rules/woozo/<file>.md`:**
   - **Does not exist** → already uninstalled for this file. Skip (no-op).
   - **Symlink pointing into this plugin's cache** (target starts with `~/.claude/plugins/cache/woozo-personal/rules/`) → `rm` it without prompting.
   - **Symlink pointing elsewhere** → show the user the current target via `readlink`, confirm before `rm`.
   - **Regular file** → user-edited copy or fork. Show its `ls -la` and first few lines, confirm strongly. Offer to rename to `<file>.md.bak` instead of deleting; only `rm` outright if the user explicitly declines the backup.

2. **Prune the namespace directory:**
   - Run `ls -A ~/.claude/rules/woozo/`. If empty, `rmdir` it.
   - If it still contains files (e.g. `.bak` from earlier installs, or unrelated user additions), leave the directory alone and list the remaining contents to the user so they decide.

3. **Verify:**
   ```sh
   ls -la ~/.claude/rules/woozo/ 2>&1
   ```
   Should report "No such file or directory" if pruned, or list only intentional remnants.

4. **Inform the user:** uninstalled; takes effect on the next session start (the current session's already-loaded rules persist until restart).

## Constraints

- **Never `rm -rf`** anything under `~/.claude/rules/`. Always inspect first.
- **Never delete `.bak` files** automatically — they're the user's safety net.
- **Touch only the owned files** under `~/.claude/rules/woozo/`. Do not modify `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, or sibling entries in `~/.claude/rules/` (e.g. `commit.md`).
