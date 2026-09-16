# Remote Grok Build

<p align="center">
  <img src="assets/grok-build.svg" alt="Grok Build" height="72" />
  &nbsp;&nbsp;
  <img src="assets/grok-bot.svg" alt="Grok Bot" height="72" />
</p>

<p align="center"><b>Grok Bot</b> ↔ <b>Grok Build</b> on a linked PC</p>

Grok Bot **Agent Plugin** (skills-only) that bridges chat to **local Grok Build** on a linked Windows PC — no public tunnels.

## What you get
- Mission control (`status`): LIVE → STALE → idle
- Streaming turns, interrupt, after-turn image/git packs
- Bidirectional media (session images ↔ chat attachments)
- Optional chief → per-project worker bots + optional RGB channel
- Idle sessions cold-open with `grok --resume` (no live hold required)

## Install
1. **Marketplace (after listing):** Settings → Plugins → search `remote-grok-build`
2. **From this repo:** submit at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish), or install locally in Cursor IDE:
   ```bash
   ln -s /path/to/remote-grok-build ~/.cursor/plugins/local/remote-grok-build
   ```
3. **Bot template:** [Add from x.ai](https://x.ai/bot/dLYpR1sSkG0VLa8-faEgX) — public Grok Bot recipe with the same skill + conventions.

## Prerequisites on the linked PC
- `grok` on PATH (`~/.grok/bin/grok.exe`)
- Optional helpers under `~/.grok-bridge/` — see `helpers/` and `docs/HELPERS.md`

## Layout
```text
plugin.json
.grok-plugin/plugin.json
skills/remote-grok-build/SKILL.md
helpers/          # optional PowerShell wrappers
docs/
```

## Not included
Secrets, personal machine paths, Cloudflare/ngrok tunnels, Cursor CloudAgent workflows.

## License
MIT

## Brand marks
See [`assets/NOTICE.md`](assets/NOTICE.md). Grok / Grok Bot / Grok Build marks © xAI.
