# woozo-personal

Personal Claude Code and Codex plugin utilities. The Claude plugin ships as `woozo` in the `woozo-personal` marketplace with `rules`, `hud`, and a set of auto-triggering workflow skills. The Codex marketplace exposes the `rules` feature and the same workflow skills through `plugins/woozo/`.

## Features

### `rules`

Behavioral rules you can opt into globally.

- **`rules/development.md`** — behavioral guidelines to reduce common LLM coding mistakes. Twelve sections: think before coding, read before write, SOLID structure what you build, behavior over data, simplicity first, match the codebase, surgical changes, surface conflicts, goal-driven execution, tests verify intent, fail loud, debug by root cause.
- **`rules/thinking.md`** — critical/objective thinking rules for every answer and judgment, not just coding: no reflexive agreement, no manufactured disagreement, scrutiny scaled to the stakes, judge claims on evidence, separate facts/inference/opinion, say "I don't know", skip empty praise.
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

### workflow skills

Methodology skills that auto-trigger during work — no activation step. Once the plugin is installed they surface whenever the situation matches their description. Prompts and outputs are in Korean.

- **`skills/brainstorming/SKILL.md`** — refines an idea into an approved design and spec before any implementation. Explores project context, asks one question at a time, proposes 2-3 approaches, presents the design section by section, and writes the spec to `docs/specs/`. Hard-gates all implementation until the spec is approved.
- **`skills/systematic-debugging/SKILL.md`** — enforces root-cause-first debugging through four phases (investigate → analyze patterns → hypothesize → implement). No fix before the root cause is understood; after three failed fixes, suspect the architecture. Ships the helpers `root-cause-tracing.md`, `defense-in-depth.md`, `condition-based-waiting.md` (with a TypeScript example), and `find-polluter.sh`. Triggers on bugs, test/build failures, and shared stack traces.
- **`skills/requesting-code-review/SKILL.md`** — dispatches a `general-purpose` sub-agent as a senior code reviewer over a git SHA range, using the `code-reviewer.md` prompt template (strengths / Critical·Important·Minor issues / merge verdict). Triggers on task or feature completion and before merge.
- **`skills/explain-diff-html/SKILL.md`** — renders a rich, interactive HTML explanation of a code change, diff, branch, or PR (background → intuition → code walkthrough → interactive quiz). Ships `render.py`, which turns a small JSON content spec into the final self-contained page (CSS/JS scaffolding, TOC, quiz-option shuffling, date-prefixed filename) so only the content is written per invocation. Recipe adapted from [Geoffrey Litt's explain-diff gist](https://gist.github.com/geoffreylitt/a29df1b5f9865506e8952488eac3d524). Triggers on requests like *"이 PR 설명해줘"* / *"explain this diff"*.

These ship to both the Claude plugin (`skills/`) and the Codex plugin (`plugins/woozo/skills/`); the two copies are kept identical.

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
- workflow skills (`brainstorming`, `systematic-debugging`, `requesting-code-review`, `explain-diff-html`) ship under `plugins/woozo/skills/`, identical to the Claude copies.
- `hud` is not exposed to Codex. The HUD remains a Claude Code-only feature under the existing Claude plugin.

The Codex plugin is intentionally self-contained under `plugins/woozo/` so the marketplace entry can resolve it with `./plugins/woozo`.

## Credits

Several features adapt prior work. Thanks to the original authors:

- **`rules/development.md`** — its *Think Before Coding*, *Simplicity First*, *Surgical Changes*, and *Goal-Driven Execution* sections trace back to [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills), a distillation of Andrej Karpathy's observations on common LLM coding mistakes (MIT).
- **`brainstorming`, `systematic-debugging`, `requesting-code-review`** adapt skills from [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent (MIT).
- **`explain-diff-html`** adapts the recipe from [Geoffrey Litt's explain-diff gist](https://gist.github.com/geoffreylitt/a29df1b5f9865506e8952488eac3d524).

## Migration from 0.x (separate `rules` / `hud` plugins)

Previous versions shipped two separate plugins. As of 1.0.0 they are merged into a single `woozo-personal` plugin. To migrate:

```bash
/plugin uninstall rules@woozo-personal
/plugin uninstall hud@woozo-personal
/plugin install woozo@woozo-personal
```

Activation skills (`rules-install`, `hud-install`, `hud-config`) keep the same behavior; only the names changed (no longer `install` / `uninstall` / `config` per sub-plugin). The `~/.claude/rules/woozo/development.md` symlink and the `~/.claude/settings.json` `statusLine` entry are preserved across the rename, but the cache path the symlink points at changes from `cache/woozo-personal/rules/...` to `cache/woozo-personal/woozo/...`. After re-running `rules-install` and `hud-install` the symlinks/settings are re-pointed at the new cache location.
