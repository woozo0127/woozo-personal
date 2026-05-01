---
name: config
description: Use this skill when the user wants to customize, tweak, debug, or troubleshoot the HUD — including changing colors, thresholds, gauge style or width, adding/removing line-2 fields (5h/7d rate limits), formatting remaining time differently, or diagnosing display issues like a blank statusline, corrupted text after percent signs, or stderr noise on every render. Trigger on phrases like "hud 색 바꿔", "ctx 게이지 너비", "rate limit 칸 빼줘", "상태바 깨짐", "statusline 디버그", "threshold 조정", "gauge style", or any explicit request to modify the HUD's appearance/behavior. Does NOT install or uninstall the HUD — see the `install` and `uninstall` skills for that.
---

# HUD config

Customize and troubleshoot the HUD's `scripts/statusline-command.sh`. The script is executed by `sh` (POSIX), not bash. Keep edits POSIX-compatible.

The HUD renders two colored lines:

```
<model> <effort> | <baseName> | <branch>[*] [wt]
ctx: <gauge> <pct>% | 5h: <pct>%(<remaining>) | 7d: <pct>%(<remaining>)
```

## When to use

- User wants to change colors, thresholds, gauge width, or formatting
- User wants to add or remove a field on line 1 or line 2
- User reports the HUD is blank, broken, or showing weird characters
- User wants to format remaining time differently

## Layout invariants

These rules every customization must preserve unless the user explicitly overrides them:

- **Line 1**: `<model> <effort> | <baseName> | <branch>[*] [wt]`
  - `<effort>` is appended only when present in the JSON payload
  - `<baseName>` is omitted when `cwd` is empty
  - `<branch>` is git branch name; `*` suffix means working tree is dirty
  - `wt` suffix appears when the session is in a git worktree
- **Line 2**: `ctx: <gauge> <pct>% | 5h: <pct>%(<remaining>) | 7d: <pct>%(<remaining>)`
  - `ctx` is always shown; if no data, displays as `0%` with empty gauge
  - `5h` and `7d` are omitted when their data is missing
  - `<remaining>` uses `Xh Ym` for 5h, day-priority `Xd Yh` for 7d (>=1d), else hours/minutes
- **Threshold colors** (applied to percentage values): `<30%` green, `30-69%` yellow, `>=70%` red
- **Base text color**: gray (256-color #245)
- All input must be guarded — never let invalid JSON values produce stderr noise or arithmetic errors

## Customization recipes

### Change color palette

The script defines `GRAY`, `GREEN`, `YELLOW`, `RED`, `RESET` near the top. Each is built with `printf '\033[...m'` and stored as literal escape characters so the rest of the script can use `%s` safely.

- ANSI standard colors: `\033[3Xm` (subdued), `\033[9Xm` (bright)
- 256-color palette: `\033[38;5;Nm` where N is 0–255

When the user asks for "darker" or "brighter" tones, present 2–3 palette options before changing — never silently pick. Useful 256-color anchors for gray: 240 (dark) / 245 (mid) / 250 (light) / 252 (very light).

### Change thresholds

The `threshold_color()` helper holds the `30` / `70` cutoffs. Adjust both numbers together so the green→yellow→red transition stays monotonic.

### Change gauge style or width

`make_gauge()` accepts a single percentage and produces a 10-wide bar. To swap characters, change the two literals (default `▰` filled, `▱` empty). Alternative styles:

- Heavy block: `█` / `░`
- Square: `▰` / `▱` (current)
- Bracketed: prepend `[` and append `]` in the call site, not in `make_gauge`

To change width, edit `width=10` inside the function. Keep width ≤ 12 — wider bars push the rest of line 2 off-screen on narrow terminals.

### Add or remove a line-2 field

Each rate-limit field is a self-contained block (`if is_numeric "$five_pct"; then ... fi`). To add a new field, mirror the block. To remove one, delete the block.

### Format remaining time differently

`fmt_remaining()` takes `(epoch, unit)` where `unit` is `hour` (default) or `day`. Add new units as additional `case` branches if needed.

## Debugging

When something looks wrong, reproduce it with a synthetic JSON payload piped into the script:

```sh
echo '{
  "model": {"display_name": "claude-opus-4-7"},
  "workspace": {"current_dir": "/path/to/repo"},
  "context_window": {"used_percentage": 42},
  "rate_limits": {
    "five_hour": {"used_percentage": 31, "resets_at": 1714600000},
    "seven_day": {"used_percentage": 8, "resets_at": 1715200000}
  }
}' | sh "${CLAUDE_PLUGIN_ROOT}/scripts/statusline-command.sh"
```

To see the raw bytes (color codes), pipe through `cat -v`. To strip ANSI for diff-friendly comparison: `sed 's/\x1b\[[0-9;]*m//g'`.

Common failure modes:

- **Blank statusline** — usually a syntax error. Run the script through `sh -n` to check syntax without executing.
- **Text after the percent looks corrupted** — `printf` is interpreting `%` as a format specifier. The script uses `%s`/`%b` defensively; if you added a new `printf` call, double-check it.
- **Stderr noise on every update** — input guard missing. Trace the value back to the `eval` block and add a `is_numeric` / `is_integer` check before arithmetic.

## Editing rules

- Preserve POSIX shell compatibility (no bash-only `[[ ]]`, no arrays, no `$(< file)`)
- Don't break the single-pass `jq` invocation — it's there for performance (10 jq calls → 1 cuts ~100–500ms per render)
- Keep input guards (`is_numeric`, `is_integer`) in front of every arithmetic / `printf "%.0f"` operation
- Don't add new external command dependencies beyond `jq`, `git`, `date`, `basename` — the script must work on a fresh macOS / Linux shell

## After editing

The script is read fresh on every status update — no restart needed. If the user reports the change isn't reflected, check whether `~/.claude/settings.json`'s `statusLine.command` actually points at this plugin's script (not a stale absolute path or a different file). Hand off to the `install` skill if re-registration is needed.
