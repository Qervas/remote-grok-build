# Remote Grok Build

<p align="center">
  <img src="assets/grok-build.svg" alt="Grok Build" height="72" />
  &nbsp;&nbsp;
  <img src="assets/grok-bot.svg" alt="Grok Bot" height="72" />
</p>

<p align="center"><b>Grok Bot</b> ↔ <b>Grok Build</b> on a linked PC</p>

Grok Bot **Agent Plugin** (skills-only) that bridges chat to **local Grok Build** on a linked Windows PC over the Grok Bot computer link. No public tunnels.

**Template v9** · plugin `0.4.5` · verified against `grok 1.0.69` (help/binary diff 2026-10-23; last live test on 1.0.63, 2026-10-18). v9 is **staged for publishing, not public yet**. See [CHANGELOG.md](CHANGELOG.md) and [docs/TEMPLATE.md](docs/TEMPLATE.md).

## What you get
- Mission control (`status`): LIVE → STALE → RUNNING → idle, with title, last-turn summary, model/effort, branch
- Streaming turns over grok's native NDJSON (`--output-format streaming-json`), background launch + tail
- Interrupt that stops only the headless turn and its child process tree (never your TUIs)
- After-turn packs: new session images/assets, git diffstat, summary, stop reason
- Bidirectional media: session images → chat; chat images → `--prompt-json` image blocks
- Optional chief → per-project worker bots + optional RGB channel
- Idle sessions cold-open with `grok -r <id>` (no live hold required)
- First-run setup skill (`rgb-getting-started`)
- **Stays current on its own:** drift check against the installed `grok` on every use, plus a daily routine that re-derives the CLI cheat sheet from the full help (`grok help`) when Grok Build ships a new release (never runs `grok update` itself). See [routines/grok-build-self-update.md](routines/grok-build-self-update.md).

## Install
1. **Marketplace (after listing):** Settings → Plugins → search `remote-grok-build`
2. **From this repo:** submit at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish), or install locally in Cursor IDE:
   ```bash
   ln -s /path/to/remote-grok-build ~/.cursor/plugins/local/remote-grok-build
   ```
3. **Bot template:** [Add from x.ai](https://x.ai/bot/dLYpR1sSkG0VLa8-faEgX): public Grok Bot recipe with the same skill and conventions. That public link still serves v6. v9 (both skills plus the daily self-update routine) is staged and not yet published.

## Prerequisites on the linked PC
- `grok` 1.0.50+ on PATH (cheat sheet: 1.0.69; last live test: 1.0.63) (`~/.grok/bin/grok.exe`), signed in
- PowerShell 5.1 or 7+
- Optional helpers under `~/.grok-bridge/`: see `helpers/` and `docs/HELPERS.md`

## Layout
```text
plugin.json
.grok-plugin/plugin.json
skills/remote-grok-build/SKILL.md
skills/rgb-getting-started/SKILL.md   # first-run setup
routines/grok-build-self-update.md    # daily self-update routine (template)
helpers/          # optional PowerShell wrappers
docs/             # ARCHITECTURE, HELPERS, TEMPLATE
CHANGELOG.md
```

## Not included
Secrets, personal machine paths, Cloudflare/ngrok tunnels, `grok agent headless` relays, Cursor CloudAgent workflows.

## License
MIT

## Brand marks
See [`assets/NOTICE.md`](assets/NOTICE.md). Grok / Grok Bot / Grok Build marks © xAI.
