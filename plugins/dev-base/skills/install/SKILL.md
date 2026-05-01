---
name: install
description: Use this skill when the user wants to install, activate, or apply the dev-base development rules globally — including phrases like "install dev-base", "activate dev-base", "dev-base 설치", "dev-base 활성화", "코딩 룰 적용", "development rules 켜기", or any explicit request to make the dev-base coding rules available in every Claude Code session. The skill creates a symlink at `~/.claude/rules/dev-base/development.md` pointing at this plugin's source rules file, so the user's existing `~/.claude/rules/*.md` auto-load mechanism picks it up at every session start. Does not modify `settings.json` or `CLAUDE.md`.
---

# dev-base install

Install the dev-base coding rules into the user's global rules directory by creating a symlink to the plugin's source file. The user's environment auto-loads `~/.claude/rules/*.md` as global instructions, so a symlink is enough — no SessionStart hook needed.

## When to use

- User asks to install / activate / enable dev-base
- User wants the development rules applied globally for the first time
- User reports the rules aren't being injected and wants to (re)install

## Files involved

- **Source (truth)**: `${CLAUDE_PLUGIN_ROOT}/rules/development.md` — never edit through the symlink; edit here
- **Target (symlink)**: `~/.claude/rules/dev-base/development.md`

## Procedure

1. **Resolve the source absolute path:**
   - First try `${CLAUDE_PLUGIN_ROOT}/rules/development.md`. If `${CLAUDE_PLUGIN_ROOT}` expands and the file exists, use that.
   - Fallback: glob `~/.claude/plugins/cache/woozo-personal/dev-base/*/rules/development.md` and pick the lexicographically largest path (latest version directory).
   - If neither resolves, abort and ask the user to run `/plugin update` for the `dev-base@woozo-personal` plugin.
   - Resolve to a true absolute path (`realpath` or `python3 -c "import os,sys;print(os.path.realpath(sys.argv[1]))"`) before using as the symlink target — relative paths break when the symlink is read from a different cwd.

2. **Ensure the target directory exists:** `mkdir -p ~/.claude/rules/dev-base`.

3. **Inspect `~/.claude/rules/dev-base/development.md`:**
   - **Does not exist** → `ln -s <abs-source> ~/.claude/rules/dev-base/development.md`. Done.
   - **Symlink pointing to the resolved source** → already installed. Tell the user, exit (no-op).
   - **Symlink pointing elsewhere** → show the user the current target via `readlink`, confirm replacement. On yes: `rm` the symlink, then `ln -s` the new one.
   - **Regular file** → likely a user-edited copy from a previous fork. Show its `ls -la` and first few lines, confirm replacement. On yes: rename to `development.md.bak` (don't delete), then `ln -s` the new one.

4. **Verify:**
   ```sh
   readlink ~/.claude/rules/dev-base/development.md
   test -f ~/.claude/rules/dev-base/development.md && head -3 ~/.claude/rules/dev-base/development.md
   ```
   The `readlink` output should match the resolved source path. The `head` output should start with `# Development Rules`.

5. **Inform the user:** installed; takes effect on the next session start (existing sessions don't re-read global rules).

## Constraints

- **Never overwrite without confirming** when the existing entry is a regular file or a foreign symlink — it may be the user's intentional customization.
- **Never edit the source `rules/development.md` through the symlink** to apply per-user tweaks. If the user wants per-machine edits, suggest forking: replace symlink with a copy (`cp -L`), then they own the file (and lose plugin-update sync).
- **Do not modify** `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, or any other entry in `~/.claude/rules/` (e.g. `commit.md`). This skill owns only `~/.claude/rules/dev-base/`.
- **Do not register a SessionStart hook.** The whole point of this skill is to replace that legacy mechanism with the file-system auto-load.
