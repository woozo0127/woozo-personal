---
name: uninstall
description: Use this skill when the user wants to uninstall, deactivate, disable, or remove the HUD statusline — including phrases like "uninstall hud", "deactivate hud", "hud 제거", "hud 비활성화", "statusline 끄기", "상태바 끄기". The skill removes the `statusLine` entry from `~/.claude/settings.json` if it points at this plugin's script. Does not touch any other field. Restart Claude Code after uninstall to clear the bar.
---

# HUD uninstall

Deactivate the HUD by removing the `statusLine` entry from `~/.claude/settings.json`. After uninstall, Claude Code shows no statusline unless the user registers a different one themselves.

## When to use

- User asks to uninstall / deactivate / disable the HUD
- User wants to switch back to no statusline or to a different one
- User is troubleshooting and wants a clean slate before reinstalling

## Procedure

1. **Read `~/.claude/settings.json`** as a JSON object. Treat a missing file as `{}`.

2. **Inspect `statusLine`:**
   - **Absent** → already uninstalled. Tell the user, exit (no-op).
   - **Present and pointing at this plugin's script** (the `command` references `${CLAUDE_PLUGIN_ROOT}/scripts/statusline-command.sh` or resolves into `~/.claude/plugins/cache/woozo-personal/hud/`) → remove the key without prompting.
   - **Present and pointing at something else** → not this plugin's HUD. Show the user the current value and confirm before removing. Strongly recommend keeping it if they don't recognize it as their own.

3. **Write `~/.claude/settings.json`** back with the `statusLine` key removed and every other field byte-stable. Use a JSON-aware edit, not regex/sed.

4. **Verify** by re-reading the file and confirming `statusLine` is absent.

5. **Inform the user:** uninstalled; restart Claude Code so the bar disappears.

## Constraints

- **Never remove a `statusLine` you don't recognize** without confirming.
- **Do not modify other `settings.json` fields.**
- **Do not delete the script itself.** It's owned by the plugin cache; `/plugin uninstall` (or marketplace removal) handles file cleanup.
