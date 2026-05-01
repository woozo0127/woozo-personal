---
name: install
description: Use this skill when the user wants to install, activate, or enable the HUD statusline shipped with this plugin — including phrases like "install hud", "activate hud", "hud 설치", "hud 활성화", "statusline 켜기", "상태바 켜기", or any explicit request to make the bottom Claude Code statusline render this plugin's two-line HUD. The skill edits `~/.claude/settings.json` to register this plugin's `scripts/statusline-command.sh` as the active `statusLine`. Does not touch any other field. Restart Claude Code after install to refresh the bar.
---

# HUD install

Activate the HUD by registering this plugin's statusline script in `~/.claude/settings.json`. Claude Code does not auto-register plugin statuslines, so this is a one-time manual write.

## When to use

- User asks to install / activate / enable the HUD
- User wants to switch from another statusLine to this one
- User reports the HUD isn't rendering and wants to (re)install

## Files involved

- **Source script**: `${CLAUDE_PLUGIN_ROOT}/scripts/statusline-command.sh`
- **Target setting**: `~/.claude/settings.json`, key `statusLine`

## Procedure

1. **Resolve the source script path.**
   - Try `${CLAUDE_PLUGIN_ROOT}/scripts/statusline-command.sh`. If `${CLAUDE_PLUGIN_ROOT}` doesn't expand inside `settings.json` on this Claude Code version, fall back to an absolute path: glob `~/.claude/plugins/cache/woozo-personal/hud/*/scripts/statusline-command.sh` and pick the lexicographically largest (latest version). Verify the file exists and is executable by `sh`.

2. **Read `~/.claude/settings.json`** as a JSON object. Treat a missing file as `{}`.

3. **Inspect any existing `statusLine`:**
   - **Absent** → safe to write directly.
   - **Present and already pointing at this plugin's script** (resolves into `~/.claude/plugins/cache/woozo-personal/hud/`) → already installed. Tell the user, exit (no-op).
   - **Present pointing somewhere else** → the user has a custom statusline (e.g. their own script). Show the current value verbatim, ask whether to replace. On no: abort without changes. On yes: tell the user to copy the old value if they want to restore it later (this skill does not back it up automatically), then proceed.

4. **Write the entry**, preserving every other field in the file. Use a JSON-aware edit, not regex/sed:
   ```json
   "statusLine": {
     "type": "command",
     "command": "sh \"${CLAUDE_PLUGIN_ROOT}/scripts/statusline-command.sh\""
   }
   ```
   Use the `${CLAUDE_PLUGIN_ROOT}` form by default. If you fell back to an absolute path in step 1, write that absolute path in the `command` field instead.

5. **Verify** by piping a synthetic JSON payload through the resolved script:
   ```sh
   echo '{
     "model": {"display_name": "claude-opus-4-7"},
     "workspace": {"current_dir": "/path/to/repo"},
     "context_window": {"used_percentage": 42},
     "rate_limits": {
       "five_hour": {"used_percentage": 31, "resets_at": 1714600000},
       "seven_day": {"used_percentage": 8, "resets_at": 1715200000}
     }
   }' | sh <resolved-script-path>
   ```
   Expect two ANSI-colored lines and exit 0. If the output is blank or there's stderr noise, hand off to the `config` skill (debugging section).

6. **Inform the user:** installed; restart Claude Code so the bar re-reads `settings.json`. Tell them to invoke the `config` skill if they want to customize colors, thresholds, or layout.

## Constraints

- **Never overwrite an unfamiliar `statusLine`** without showing it to the user and confirming.
- **Do not modify other `settings.json` fields.** Use a JSON-aware read/edit/write so unrelated keys (model, theme, enabledPlugins, etc.) are byte-stable.
- **Do not register hooks, skills, or anything else.** Install only writes the `statusLine` entry.
