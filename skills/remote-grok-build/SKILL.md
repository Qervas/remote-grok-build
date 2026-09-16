---
name: remote-grok-build
description: >-
  Use this when bridging Grok Bot chat to local Grok Build on a linked Windows
  PC — mission control, streaming, interrupt, media packs; optionally suggest
  chief→per-project workers and an RGB channel for parallel work.
---
# Remote Grok Build bridge

Drive **local Grok Build** (`grok`) on a registered user computer from Grok Bot chat — mission-control cockpit, same-session resume, bidirectional media.

**Optional (suggested at scale):** chief → per-project worker bots, plus an optional shared channel to house them.

## When this applies
- Remote control of local Grok Build / Grok CLI on a linked PC
- `status`, pick project/session, send a turn, stop a turn, shuttle images
- Growing to several projects without single-thread context mush

Not for Cursor cloud agents. Access is via **Grok Bot computer link only** (no public tunnels).

## Operating modes

### A) Single bot (always valid)
One assistant runs mission control **and** executes turns. Default for light use. Never force multi-bot on a user who only has one project.

### B) Chief + workers (optional, **suggested** when…)
Suggest (don't require) multi-bot dispatch when any of these show up:
- Two or more active projects / parallel turns
- Session transcripts getting huge or mixed
- User asks for "one bot per project" or "dispatch"

| Role | Responsibility |
|------|----------------|
| **Chief** | Mission control UI, project→bot registry, optional dispatch, fan-in. Avoid hoarding every project's long Grok history. |
| **Worker** (1 per project folder) | Pinned `cwd` + `session_id`, `grok --resume`, streaming, interrupt, after-turn pack, images. |

**Naming:** `RGB <short-project>` (e.g. `RGB games`).  
**Registry (chief memory):** `cwd` → worker agent id + last `session_id` + title.  
**Create** workers with `CreateAgent` on first assign; **reuse** afterward.  
**Dispatch** with `SendToAgent` (async). Chief may run several workers in parallel.  
**Fan-out:** ask before messaging many workers unless the user explicitly said to.

When suggesting, one short offer is enough ("Want a worker bot for this project so we can run it in parallel?"). If they decline, stay single-bot.

### C) Optional RGB channel
Also optional: a standing **agent group channel** for Remote Grok Build bots.

- Create with `CreateChannel` only when the user asks or clearly wants a room (creating a channel is a visible sidebar side effect — never speculative).
- Suggested name: `Remote Grok Build` or `RGB`.
- Seat the **chief** (include chief's own agent id in `member_ids`) and add workers over time with `UpdateChannel`.
- Cap / practicality: channels seat a limited number of members — keep the set to chief + active workers; don't auto-invite every idle project bot.
- Post dispatches and short status into the channel with `SendToAgent` targeting the channel id when coordination should be visible to all RGB bots; keep user-facing narrative in the user's chat with the chief unless they're in the channel UI.

Channel is for **bot coordination**, not a replacement for mission-control widgets in the user↔chief chat.

## Worker bootstrap (when creating one)
> You are a Remote Grok Build **project worker**. You own one project folder on the user's linked PC. Remember `cwd` + `session_id`. Run the Remote Grok Build skill for turns, streaming, interrupt, and after-turn packs. Do not steal other projects' sessions. When the chief dispatches you, reply with RGB_RESULT (and RGB_PROGRESS as useful).

## Prerequisites
- Linked computer with `grok` on PATH (`~/.grok/bin/grok.exe`)
- Optional helpers under `~/.grok-bridge/`:
  - `grok-mission-control.ps1`
  - `grok-after-turn.ps1`
  - `grok-interrupt.ps1`

## Storage map (`~/.grok`)
| Path | Role |
|------|------|
| `active_sessions.json` | Live `session_id` / `pid` / `cwd` |
| `sessions/<url-encoded-cwd>/<session-id>/` | All sessions |
| `…/summary.json` | Title, times, model, recap |
| `…/images/` · `…/assets/` | Session media |
| `trusted_folders.toml` | Trusted projects |
| `config.toml` / `auth.json` | **Never paste secrets into chat** |

## 1) Mission control (`status`)
**Order:** LIVE → STALE → idle/history (newest first), by folder.  
Widgets (max 6): LIVE, then idle projects, then sessions.  
If a worker already owns that `cwd`, offer dispatch to that worker.

## Idle / not-live sessions
Do **not** require holding a session LIVE before a remote chat turn. Cold-open idle with headless `grok --resume <session_id>` from the project cwd. Holding LIVE is optional — only for LIVE-tier mission-control visibility or watching a TUI.

## 2) Live progress (streaming)
```powershell
Set-Location '<cwd>'
grok --resume '<session_id>' -p '<intent>' --always-approve --output-format streaming-json
```
Sparse milestone updates while running.

## 3) Stop / interrupt
Stop headless `grok` matching `session_id`. Chief forwards stop to the owning worker in multi-bot mode.

## 4) After-turn pack
Reply + **new images** into chat + git diffstat + build notes if any.

## Bidirectional media
Out: session images → chat. In: attachments → stage on PC → `--prompt-json` or path.

## Chief ↔ worker protocol (when multi-bot is on)
```text
RGB_DISPATCH
cwd: <path>
session_id: <uuid|ASK>
intent: <ask>
flags: stream=1 always_approve=1
```
```text
RGB_RESULT
cwd: …
session_id: …
status: ok|error|stopped
summary: …
images: …
git: …
```
Optional: `RGB_PROGRESS …`

## Controls / session ops / optional extras
Model/effort, fork vs share TUI, pins, `grok export`, desktop screenshot, done ping.

## Do not
- Require workers or a channel for simple one-project use  
- Create channels or workers speculatively  
- Fan out without a clear ask  
- Require a live hold before resuming idle sessions  
- Public tunnels; hide idle sessions; leave images on disk only; paste grok secrets; use Cursor CloudAgent for this
