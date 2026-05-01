# woozo-personal

Personal Claude Code marketplace.

## Plugins

### `rules`

Behavioral rules you can opt into globally.

- **`rules/development.md`** — behavioral guide for coding tasks: clarify before coding, read context first, small scoped changes, YAGNI, debug to root cause, verify before claiming done, boundaries and interfaces, naming, blast-radius awareness, surface trade-offs, plus a methodology catalog (TDD, Refactoring, SOLID, DDD, YAGNI, KISS, DRY).
- **`rules/communication.md`** — communication guide for user-facing output: file paths are always written as absolute paths, never relative or `~`-shortened.
- **`skills/install/SKILL.md`** — installs the rules globally by symlinking each file into `~/.claude/rules/woozo/` (e.g. `~/.claude/rules/woozo/development.md`, `~/.claude/rules/woozo/communication.md`). Picked up by the user's existing `~/.claude/rules/*.md` auto-load mechanism on the next session. The `woozo/` subdirectory keeps the plugin's files namespaced so they don't collide with sibling rules like `commit.md`.
- **`skills/uninstall/SKILL.md`** — removes the symlinks and prunes the empty `woozo/` directory.

After installing the plugin, ask Claude something like *"rules 설치"* / *"install rules"*. Plugin install alone does nothing — activation is explicit.

### `hud`

2-line ANSI statusline HUD with colored context gauge and 5h/7d rate-limit usage.

```
claude-opus-4-7 medium | pumpu-log | feat/home wt
ctx: ▰▰▰▰▱▱▱▱▱▱ 42% | 5h: 31%(2h15m) | 7d: 8%(1d3h)
```

- **`scripts/statusline-command.sh`** — POSIX shell script that Claude Code invokes per status update. Single `jq` pass, threshold-based coloring (`<30%` green / `<70%` yellow / `>=70%` red), 10-wide gauge for context, day-priority remaining time for 7d.
- **`skills/install/SKILL.md`** — registers the script in `~/.claude/settings.json` as the active `statusLine`.
- **`skills/uninstall/SKILL.md`** — removes the `statusLine` entry.
- **`skills/config/SKILL.md`** — customization recipes (color, threshold, gauge style/width, line-2 fields, remaining-time format) and debugging procedures.

After installing the plugin, ask Claude something like *"HUD 켜줘"* / *"install the HUD"*. To customize later: *"HUD 색 바꿔줘"* triggers the `config` skill.

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
/plugin install rules@woozo-personal
/plugin install hud@woozo-personal
```

After plugin install, activate each plugin explicitly via its `install` skill (see plugin sections above).
