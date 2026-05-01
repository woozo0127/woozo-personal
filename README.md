# woozo-personal

Personal Claude Code marketplace.

## Plugins

### `dev-base`

Injects development rules into every session.

- **`rules/development.md`** — behavioral guide for coding tasks: clarify before coding, read context first, small scoped changes, YAGNI, debug to root cause, verify before claiming done, boundaries and interfaces, naming, blast-radius awareness, surface trade-offs, plus a methodology catalog (TDD, Refactoring, SOLID, DDD, YAGNI, KISS, DRY).
- **`hooks/hooks.json`** — `SessionStart` hook that prints the rule file so Claude Code loads it as session context.

### `hud`

2-line ANSI statusline HUD with colored context gauge and 5h/7d rate-limit usage.

```
claude-opus-4-7 medium | pumpu-log | feat/home wt
ctx: ▰▰▰▰▱▱▱▱▱▱ 42% | 5h: 31%(2h15m) | 7d: 8%(1d3h)
```

- **`scripts/statusline-command.sh`** — POSIX shell script that Claude Code invokes per status update. Single `jq` pass, threshold-based coloring (`<30%` green / `<70%` yellow / `>=70%` red), 10-wide gauge for context, day-priority remaining time for 7d.
- **`skills/hud-setup/SKILL.md`** — Skill that helps customize, install, or debug the HUD (colors, thresholds, gauge style, etc.).

After installing the plugin, just ask Claude something like *"HUD 켜줘"* / *"enable the HUD statusline"*. The bundled `hud` skill triggers and edits `~/.claude/settings.json` for you (it preserves any existing `statusLine` value and asks before overwriting).

Manual setup, if you prefer:

```json
{
  "statusLine": {
    "type": "command",
    "command": "sh \"${CLAUDE_PLUGIN_ROOT}/scripts/statusline-command.sh\""
  }
}
```

If `${CLAUDE_PLUGIN_ROOT}` doesn't expand in your Claude Code version, use the absolute path under `~/.claude/plugins/cache/woozo-personal/hud/scripts/statusline-command.sh`.

## Install

```bash
/plugin marketplace add woozo0127/woozo-personal
/plugin install dev-base@woozo-personal
/plugin install hud@woozo-personal
```
