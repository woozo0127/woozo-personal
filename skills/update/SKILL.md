---
name: update
description: Use this skill when the user has updated (or wants to apply an update of) the woozo plugin and needs installed features re-pointed at the latest plugin version — including phrases like "플러그인 업데이트 적용", "update 적용", "rules 최신화", "심링크 갱신", "apply plugin update", or after running `/plugin update` / `claude plugin update woozo@woozo-personal`. The skill re-points the `~/.claude/rules/woozo/` symlinks and the `statusLine` path in `~/.claude/settings.json` at the latest cached version. It does not run the plugin update itself, does not install features that aren't installed, and does not delete old cache directories.
---

# update

Re-point installed woozo features at the latest plugin cache version after a plugin update. Complements `rules-install` and `hud-install` (first-time installs); this skill only refreshes existing references.

Keep in sync with `rules-install` (symlink handling) and `hud-install` (statusLine registration) — if their procedures change, mirror the change here.

## When to use

- User updated the plugin (`/plugin update` or `claude plugin update woozo@woozo-personal`) and wants the update applied
- Rules symlinks or the HUD statusline still point at an old version's cache path
- User asks to apply the plugin update, refresh the rules symlinks, or fix a stale statusline path

## Owned targets

- Symlinks under `~/.claude/rules/woozo/` that point into this plugin's cache (`~/.claude/plugins/cache/woozo-personal/woozo/`)
- The `statusLine.command` entry in `~/.claude/settings.json`, only when it references this plugin's cache path

Never touch entries outside `~/.claude/rules/woozo/` (e.g. `~/.claude/rules/commit.md`) or other `settings.json` fields.

## Procedure

1. **Resolve the latest cache root:**
   - First try `${CLAUDE_PLUGIN_ROOT}`. If it expands and contains `rules/`, use it.
   - Fallback: glob `~/.claude/plugins/cache/woozo-personal/woozo/*/` and pick the lexicographically largest version directory.
   - If neither resolves, abort and tell the user to run `claude plugin update woozo@woozo-personal` (or `/plugin update`) first, then re-run this skill.
   - Resolve to a true absolute path (`realpath`) before creating symlinks.

2. **Sync rules symlinks** — skip this step entirely if no entry under `~/.claude/rules/woozo/` is a symlink into this plugin's cache (rules not installed; installing is `rules-install`'s job). Otherwise:
   - Symlink pointing into this plugin's cache but not at the resolved latest root → `rm` it, then `ln -s` the latest source (own namespace, no confirmation needed).
   - `<file>.md` present in the latest cache's `rules/` with no entry at `~/.claude/rules/woozo/<file>.md` → `ln -s` it (a rule file added by the update).
   - Symlink into this plugin's cache whose source file no longer exists in the latest version → `rm` it (avoids dangling links).
   - Regular file or symlink pointing elsewhere → leave untouched and report it to the user.

3. **Sync the HUD statusline** — inspect `statusLine.command` in `~/.claude/settings.json`:
   - Contains a path under `~/.claude/plugins/cache/woozo-personal/woozo/` with a version other than the latest → rewrite only that path to the latest version directory.
   - Absent, or pointing anywhere else → skip and report (HUD not installed, or user customization).

4. **Verify:**
   ```sh
   for f in ~/.claude/rules/woozo/*.md; do echo "$f -> $(readlink "$f")"; done
   grep -o '"command"[^,}]*' ~/.claude/settings.json
   head -1 ~/.claude/rules/woozo/*.md
   ```
   Every woozo symlink and the statusLine path should reference the resolved latest version directory, and each rule file should render its own `# ...` header.

5. **Inform the user:** summarize what was re-pointed, added, removed, or skipped. Global rules and the statusline are re-read at session start — recommend restarting Claude Code or opening a new session.

## Constraints

- Do not run the plugin update itself — this skill only applies one.
- Do not install features that are not installed; that's `rules-install` / `hud-install`.
- Do not delete cache directories.
- Never overwrite regular files or foreign symlinks — report them instead.
- Do not modify `settings.json` fields other than `statusLine.command`.
