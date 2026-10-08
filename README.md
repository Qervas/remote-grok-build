# Remote Grok Build

<p align="center">
  <img src="assets/grok-build.svg" alt="Grok Build" height="72" />
  &nbsp;&nbsp;
  <img src="assets/grok-bot.svg" alt="Grok Bot" height="72" />
</p>

<p align="center"><b>Grok Bot</b> ↔ <b>Grok Build</b> on a linked PC</p>

Grok Bot **Agent Plugin** (skills-only) that bridges chat to **local Grok Build** on a linked Windows PC over the Grok Bot computer link. No public tunnels.

**Template v7** · plugin `0.2.0` · verified against `grok 1.0.50` (Oct 2026). See [CHANGELOG.md](CHANGELOG.md).

## What you get
- Mission control (`status`): LIVE → STALE → RUNNING → idle, with title, last-turn summary, model/effort, branch
- Streaming turns over grok's native NDJSON (`--output-format streaming-json`), background launch + tail
- Interrupt that stops only the headless turn and its child process tree (never your TUIs)
- After-turn packs: new session images/assets, git diffstat, summary, stop reason
- Bidirectional media: session images → chat; chat images → `--prompt-json` image blocks
- Optional chief → per-project worker bots + optional RGB channel
- Idle sessions cold-open with `grok -r <id>` (no live hold required)
- **Stays current on its own:** drift check against the installed `grok` on every use, plus a daily routine that re-derives the CLI cheat sheet from `--help` when Grok Build ships a new release (never runs `grok update` itself)

## Install
1. **Marketplace (after listing):** Settings → Plugins → search `remote-grok-build`
2. **From this repo:** submit at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish), or install locally in Cursor IDE:
   ```bash
   ln -s /path/to/remote-grok-build ~/.cursor/plugins/local/remote-grok-build
   ```
3. **Bot template:** [Add from x.ai](https://x.ai/bot/dLYpR1sSkG0VLa8-faEgX): public Grok Bot recipe with the same skill and conventions. The published template is still v6; this repo is v7.

## Prerequisites on the linked PC
- `grok` 1.0.50+ on PATH (`~/.grok/bin/grok.exe`), signed in
- PowerShell 5.1 or 7+
- Optional helpers under `~/.grok-bridge/`: see `helpers/` and `docs/HELPERS.md`

## Layout
```text
plugin.json
.grok-plugin/plugin.json
skills/remote-grok-build/SKILL.md
helpers/          # optional PowerShell wrappers
docs/
CHANGELOG.md
```

## Not included
Secrets, personal machine paths, Cloudflare/ngrok tunnels, `grok agent headless` relays, Cursor CloudAgent workflows.

## License
MIT

## Brand marks
See [`assets/NOTICE.md`](assets/NOTICE.md). Grok / Grok Bot / Grok Build marks © xAI.
