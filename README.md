# woozo-personal

Personal Claude Code and Codex plugin utilities. The Claude plugin ships as `woozo` in the `woozo-personal` marketplace with `rules` and `hud` features. The Codex marketplace exposes only the `rules` feature through `plugins/woozo/`.

## Features

### `rules`

Behavioral rules you can opt into globally.

- **`rules/development.md`** — behavioral guidelines to reduce common LLM coding mistakes. Thirteen sections: think before coding, simplicity first, surgical changes, goal-driven execution, surface conflicts, read before write, tests verify intent, checkpoint after every step, match the codebase, fail loud, TDD contract first, design before build, debug by root cause.
- **`rules/thinking.md`** — critical/objective thinking rules for every answer and judgment, not just coding: no reflexive agreement, judge claims on evidence, separate facts/inference/opinion, say "I don't know", skip empty praise.
- **`skills/rules-install/SKILL.md`** — installs the rules globally by symlinking each file under `rules/` into `~/.claude/rules/woozo/`. Picked up by the user's existing `~/.claude/rules/*.md` auto-load mechanism on the next session. The `woozo/` subdirectory keeps the plugin's files namespaced so they don't collide with sibling rules like `commit.md`.
- **`skills/rules-uninstall/SKILL.md`** — removes the symlinks (and any leftover `communication.md` symlink from earlier versions) and prunes the empty `woozo/` directory.

After installing the plugin, ask Claude something like *"rules 설치"* / *"install rules"*. Plugin install alone does nothing — activation is explicit.

### `hud`

2-line ANSI statusline HUD with colored context gauge and 5h/7d rate-limit usage.

```
claude-opus-4-7 medium | pumpu-log | feat/home wt
ctx: ████░░░░░░ 42% | 5h: 31%(2h15m) | 7d: 8%(1d3h)
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

### `update`

Applies a plugin update to installed features. After `/plugin update` (or `claude plugin update woozo@woozo-personal`), ask Claude something like *"업데이트 적용"* / *"apply the plugin update"*.

- **`skills/update/SKILL.md`** — re-points the `~/.claude/rules/woozo/` symlinks and the `statusLine` path in `~/.claude/settings.json` at the latest cached version. Only refreshes features that are already installed; never installs, uninstalls, or prunes caches.
- **`plugins/woozo/skills/update/SKILL.md`** — Codex counterpart: re-syncs the managed Woozo blocks in `~/.codex/AGENTS.md` with the latest rule files, appending blocks for newly shipped rules.

## Claude Code Install

```bash
/plugin marketplace add woozo0127/woozo-personal
/plugin install woozo@woozo-personal
```

After plugin install, activate each feature explicitly via its skill:

- `rules` → ask Claude *"rules 설치"* (triggers `rules-install`)
- `hud` → ask Claude *"HUD 설치"* (triggers `hud-install`)

## Codex Marketplace

Codex support uses this repository as a marketplace. The marketplace catalog lives at `.agents/plugins/marketplace.json` and points to the Codex plugin under `plugins/woozo/`.

Feature support:

- `rules` installs into `~/.codex/AGENTS.md` as managed Woozo blocks (one per rule file).
- `hud` is not exposed to Codex. The HUD remains a Claude Code-only feature under the existing Claude plugin.

The Codex plugin is intentionally self-contained under `plugins/woozo/` so the marketplace entry can resolve it with `./plugins/woozo`.

## Migration from 0.x (separate `rules` / `hud` plugins)

Previous versions shipped two separate plugins. As of 1.0.0 they are merged into a single `woozo-personal` plugin. To migrate:

```bash
/plugin uninstall rules@woozo-personal
/plugin uninstall hud@woozo-personal
/plugin install woozo@woozo-personal
```

Activation skills (`rules-install`, `hud-install`, `hud-config`) keep the same behavior; only the names changed (no longer `install` / `uninstall` / `config` per sub-plugin). The `~/.claude/rules/woozo/development.md` symlink and the `~/.claude/settings.json` `statusLine` entry are preserved across the rename, but the cache path the symlink points at changes from `cache/woozo-personal/rules/...` to `cache/woozo-personal/woozo/...`. After re-running `rules-install` and `hud-install` the symlinks/settings are re-pointed at the new cache location.
