---
name: uninstall
description: Use this skill when the user wants to uninstall, deactivate, disable, or remove the dev-base development rules — including phrases like "uninstall dev-base", "deactivate dev-base", "dev-base 제거", "dev-base 비활성화", "코딩 룰 끄기", "development rules 끄기". The skill removes `~/.claude/rules/dev-base/development.md` and prunes the empty directory, undoing what the install skill set up. Does not modify `settings.json` or `CLAUDE.md`.
---

# dev-base uninstall

Remove the dev-base coding rules from the user's global rules directory.

## When to use

- User asks to uninstall / deactivate / disable dev-base
- User wants to stop the development rules from being injected globally
- User is troubleshooting and wants a clean slate before reinstalling

## Procedure

1. **Inspect `~/.claude/rules/dev-base/development.md`:**
   - **Does not exist** → already uninstalled. Tell the user, exit (no-op).
   - **Symlink pointing into this plugin's cache** (target starts with `~/.claude/plugins/cache/woozo-personal/dev-base/`) → `rm` it without prompting.
   - **Symlink pointing elsewhere** → show the user the current target via `readlink`, confirm before `rm`.
   - **Regular file** → user-edited copy or fork. Show its `ls -la` and first few lines, confirm strongly. Offer to rename to `development.md.bak` instead of deleting; only `rm` outright if the user explicitly declines the backup.

2. **Prune the directory:**
   - Run `ls -A ~/.claude/rules/dev-base/`. If empty, `rmdir` it.
   - If it still contains files (e.g. `.bak` from earlier installs, or unrelated user additions), leave the directory alone and list the remaining contents to the user so they decide.

3. **Verify:**
   ```sh
   ls -la ~/.claude/rules/dev-base/ 2>&1
   ```
   Should report "No such file or directory" if removed, or list only intentional remnants.

4. **Inform the user:** uninstalled; takes effect on the next session start (the current session's already-loaded rules persist until restart).

## Constraints

- **Never `rm -rf`** anything under `~/.claude/rules/`. Always inspect first.
- **Never delete `.bak` files** automatically — they're the user's safety net.
- **Do not touch other entries** in `~/.claude/rules/` (like `commit.md`) or any sibling files. This skill owns only `~/.claude/rules/dev-base/`.
- **Do not modify** `~/.claude/CLAUDE.md` or `~/.claude/settings.json`.
