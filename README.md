# woozo-personal

Personal Claude Code plugin. The repository ships as a single plugin (`woozo`) hosted in the `woozo-personal` marketplace, bundling two features — `rules` and `hud` — exposed as five skills.

## Features

### `rules`

Behavioral rules you can opt into globally.

- **`rules/development.md`** — behavioral guidelines to reduce common LLM coding mistakes. Four sections: think before coding, simplicity first, surgical changes, goal-driven execution.
- **`skills/rules-install/SKILL.md`** — installs the rule globally by symlinking `rules/development.md` into `~/.claude/rules/woozo/development.md`. Picked up by the user's existing `~/.claude/rules/*.md` auto-load mechanism on the next session. The `woozo/` subdirectory keeps the plugin's files namespaced so they don't collide with sibling rules like `commit.md`.
- **`skills/rules-uninstall/SKILL.md`** — removes the symlink (and any leftover `communication.md` symlink from earlier versions) and prunes the empty `woozo/` directory.

After installing the plugin, ask Claude something like *"rules 설치"* / *"install rules"*. Plugin install alone does nothing — activation is explicit.

### `hud`

2-line ANSI statusline HUD with colored context gauge and 5h/7d rate-limit usage.

```
claude-opus-4-7 medium | pumpu-log | feat/home wt
ctx: ▰▰▰▰▱▱▱▱▱▱ 42% | 5h: 31%(2h15m) | 7d: 8%(1d3h)
```

- **`scripts/statusline-command.sh`** — POSIX shell script that Claude Code invokes per status update. Single `jq` pass, threshold-based coloring (`<30%` green / `<70%` yellow / `>=70%` red), 10-wide gauge for context, day-priority remaining time for 7d.
- **`skills/hud-install/SKILL.md`** — registers the script in `~/.claude/settings.json` as the active `statusLine`.
- **`skills/hud-uninstall/SKILL.md`** — removes the `statusLine` entry.
- **`skills/hud-config/SKILL.md`** — customization recipes (color, threshold, gauge style/width, line-2 fields, remaining-time format) and debugging procedures.

After installing the plugin, ask Claude something like *"HUD 켜줘"* / *"install the HUD"*. To customize later: *"HUD 색 바꿔줘"* triggers the `hud-config` skill.

Manual setup, if you prefer:

```json
{
  "statusLine": {
    "type": "command",
    "command": "sh \"${CLAUDE_PLUGIN_ROOT}/scripts/statusline-command.sh\""
  }
}
```

If `${CLAUDE_PLUGIN_ROOT}` doesn't expand in your Claude Code version, use the absolute path under `~/.claude/plugins/cache/woozo-personal/woozo/<version>/scripts/statusline-command.sh`.

## Install

```bash
/plugin marketplace add woozo0127/woozo-personal
/plugin install woozo@woozo-personal
```

After plugin install, activate each feature explicitly via its skill:

- `rules` → ask Claude *"rules 설치"* (triggers `rules-install`)
- `hud` → ask Claude *"HUD 설치"* (triggers `hud-install`)

## Migration from 0.x (separate `rules` / `hud` plugins)

Previous versions shipped two separate plugins. As of 1.0.0 they are merged into a single `woozo-personal` plugin. To migrate:

```bash
/plugin uninstall rules@woozo-personal
/plugin uninstall hud@woozo-personal
/plugin install woozo@woozo-personal
```

Activation skills (`rules-install`, `hud-install`, `hud-config`) keep the same behavior; only the names changed (no longer `install` / `uninstall` / `config` per sub-plugin). The `~/.claude/rules/woozo/development.md` symlink and the `~/.claude/settings.json` `statusLine` entry are preserved across the rename, but the cache path the symlink points at changes from `cache/woozo-personal/rules/...` to `cache/woozo-personal/woozo/...`. After re-running `rules-install` and `hud-install` the symlinks/settings are re-pointed at the new cache location.
