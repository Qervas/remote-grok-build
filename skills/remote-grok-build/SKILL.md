---
name: remote-grok-build
description: >-
  Use this when bridging Grok Bot chat to local Grok Build (the grok CLI) on a
  linked Windows PC: mission control, streaming turns, interrupt, media packs;
  optionally suggest chief→per-project workers and an RGB channel for parallel work.
---
# Remote Grok Build bridge (template v7)

Drive **local Grok Build** (`grok`) on a registered user computer from Grok Bot chat: mission-control cockpit, same-session resume, live streaming, interrupt, bidirectional media.

**Verified against:** `grok 1.0.50` (Oct 2026). v6 targeted the ~1.0.3x/1.0.40 CLI. Check the installed version first (`grok --version`, or `grok update --check --json`) and re-read `grok --help` when it has moved past 1.0.50.

**Optional (suggested at scale):** chief → per-project worker bots, plus an optional shared channel for them.

## When this applies
- Remote control of local Grok Build / Grok CLI on a linked PC
- `status`, pick a project/session, send a turn, stop a turn, shuttle images
- Growing to several projects without one thread's context turning to mush

Not for Cursor cloud agents. Access is through the **Grok Bot computer link only** (authenticated home access, no public tunnels, no Cloudflare/ngrok, no `grok agent headless`/`serve` relays).

## Operating modes

### A) Single bot (always valid)
One assistant runs mission control **and** executes turns. Default for light use. Never push multi-bot on a user who only has one project.

### B) Chief + workers (optional, **suggested** when…)
Suggest (don't require) multi-bot dispatch when any of these show up:
- Two or more active projects or parallel turns
- Session transcripts getting huge or mixed
- User asks for "one bot per project" or "dispatch"

| Role | Responsibility |
|------|----------------|
| **Chief** | Mission control UI, project→bot registry, optional dispatch, fan-in. Avoid hoarding every project's long Grok history. |
| **Worker** (1 per project folder) | Pinned `cwd` + `session_id`, headless resume, streaming, interrupt, after-turn pack, images. |

**Naming:** `RGB <short-project>` (e.g. `RGB games`).
**Registry (chief memory):** `cwd` → worker agent id + last `session_id` + title.
**Create** workers with `CreateAgent` on first assign; **reuse** afterward.
**Dispatch** with `SendToAgent` (async). The chief may run several workers in parallel.
**Fan-out:** ask before messaging many workers unless the user explicitly said to.

When suggesting, one short offer is enough ("Want a worker bot for this project so we can run it in parallel?"). If they decline, stay single-bot.

### C) Optional RGB channel
A standing **agent group channel** for Remote Grok Build bots, also optional.
- Create with `CreateChannel` only when the user asks or clearly wants a room (a channel is a visible sidebar side effect, never speculative).
- Suggested name: `Remote Grok Build` or `RGB`.
- Seat the **chief** (include its own agent id in `member_ids`) and add workers over time with `UpdateChannel`.
- Keep the set to chief + active workers; don't auto-invite every idle project bot.
- Post dispatches and short status into the channel with `SendToAgent` (channel id) when coordination should be visible to all RGB bots; keep the user-facing narrative in the user↔chief chat.

The channel is for **bot coordination**, not a replacement for mission-control widgets.

## Worker bootstrap (when creating one)
> You are a Remote Grok Build **project worker**. You own one project folder on the user's linked PC. Remember `cwd` + `session_id`. Run the Remote Grok Build skill for turns, streaming, interrupt, and after-turn packs. Do not steal other projects' sessions. When the chief dispatches you, reply with RGB_RESULT (and RGB_PROGRESS as useful).

## Prerequisites
- Linked computer with `grok` on PATH (`~/.grok/bin/grok.exe`), signed in (`grok login`)
- Optional helpers under `~/.grok-bridge/` (from the plugin's `helpers/`):
  - `grok-mission-control.ps1`: LIVE / STALE / RUNNING / idle inventory
  - `grok-turn.ps1`: launch a headless turn in the background, NDJSON to a log
  - `grok-interrupt.ps1`: stop a headless turn (process tree) by session id
  - `grok-after-turn.ps1`: reply pack (new images, git, summary)

## CLI cheat sheet (grok 1.0.50)
| Need | Use |
|------|-----|
| Version / update state | `grok --version` · `grok update --check --json` (don't run `grok update` unasked) |
| List / search sessions | `grok sessions list -n 20` · `grok sessions search "<q>" -n 20`. **Scoped to the current directory**, so run them from (or `--cwd`) the project folder. For an all-folders view, scan `~/.grok/sessions` (mission control). Never run `grok sessions delete` unasked. |
| Resume a turn | `grok --cwd '<cwd>' -r '<session_id>' -p '<text>'`. `-r` also takes a title (case-insensitive, current dir only), but scripts should pass the UUID. `-c` = most recent in cwd. |
| Fork instead of append | add `--fork-session` (optionally `-s <new-uuid>` to name the fork) |
| New session with a known id | `-s <uuid>` (must be a fresh valid UUID; **no longer upserts or resumes**) |
| Long / quoted prompt | `--prompt-file <path>` (avoids PowerShell quoting); `--prompt-json '<blocks>'` for content blocks (images) |
| Live progress | `--output-format streaming-json` (xAI-native NDJSON) |
| Messages-API stream | `--output-format streaming-messages-json` [+ `--include-partial-messages` for deltas] |
| Final result + session id + spend | `--output-format json` → `text`, `stopReason`, `sessionId`, `usage`, `num_turns`, `modelUsage` |
| Approvals | `--always-approve` (alias `--yolo`, = `--permission-mode bypassPermissions`). Others: `default`, `acceptEdits`, `auto`, `dontAsk`, `plan`. `--allow`/`--deny` rules still apply. |
| Model / effort | `-m <model>` (`grok models` lists them) · `--effort none…max` (model-dependent, e.g. `xhigh`) |
| Guardrails | `--max-turns N`, `--tools`, `--disallowed-tools`, `--rules`, `--sandbox <profile>`, `--no-subagents` |
| Quiet updates during a turn | `--no-auto-update` (or env `GROK_DISABLE_AUTOUPDATER=1`) |
| Transcript / spend | `grok export <id> [out.md]` · `grok usage <id> [turn]` |
| Worktrees | `-w [name]` (+ `--worktree-ref <ref>`); with a remote session `--restore-code` |
| Agent dashboard (TUI) | `grok dashboard` (local screen only) |

## Storage map (`~/.grok`)
| Path | Role |
|------|------|
| `active_sessions.json` | Open TUI sessions: `session_id` / `pid` / `cwd` / `opened_at` (may be stale; check the pid) |
| `sessions/<url-encoded-cwd>/<session-id>/` | All sessions (`[uri]::EscapeDataString(cwd)`) |
| `…/summary.json` | Index entry: `info.id`, `info.cwd`, `generated_title`, `session_summary`, `last_turn_summary`, `last_recap`, `current_model_id`, `reasoning_effort`, `agent_name`, `head_branch`, `updated_at`/`last_active_at`, `num_chat_messages` |
| `…/updates.jsonl` | Authoritative ACP update log (`_x.ai/session/update` lines: `agent_message_chunk`, `tool_call`, `turn_completed`, `session_recap`, …) |
| `…/events.jsonl` · `usage.json` · `signals.json` | Event log, token/cost usage, turn signals |
| `…/images/` · `…/assets/` | Session media (images the user/agent attached, generated assets) |
| `…/terminal/` · `compaction/` · `subagents/` | Tool command logs, compaction segments, child sessions |
| `version.json` | Cached installed/latest version from the update check |
| `trusted_folders.toml` | Trusted projects |
| `config.toml` / `auth.json` / `mcp_credentials.json` | **Never read into chat or paste secrets** |

**Auto-update gotcha:** when grok self-updates while a TUI is open, the running binary is renamed to `grok.exe.old`. That TUI keeps the old version; `Get-Process` names it `grok.exe.old` while CIM still says `grok.exe`. Match processes by PID from `active_sessions.json`, not by process name, and label such a LIVE row "old binary" (it picks up the new version on its next launch).

## 1) Mission control (`status`)
Run `grok-mission-control.ps1` (or scan `~/.grok` the same way).
**Order:** LIVE → STALE → RUNNING headless → idle/history (newest first), by folder.
Widgets (max 6): LIVE, then idle projects, then sessions. Show title, last turn summary, model/effort, branch.
If a worker already owns that `cwd`, offer dispatch to that worker.

## Idle / not-live sessions
Do **not** require a LIVE hold before a remote chat turn. Cold-open idle sessions with headless `grok -r <session_id> -p …` and `--cwd` set to the session's folder (`summary.json` → `info.cwd`). Holding LIVE is optional, only for LIVE-tier visibility or watching a TUI. If the folder no longer exists, grok now fails fast; tell the user rather than recreating it.

Avoid driving the **same** session headless while its TUI is open and busy (two writers); offer `--fork-session` or wait.

## 2) Send a turn with live progress (streaming)
Preferred: background launch + tail, so the bot can post milestones and still interrupt.
```powershell
& "$HOME\.grok-bridge\grok-turn.ps1" -Cwd '<cwd>' -SessionId '<session_id>' -Prompt '<intent>'
# → prints PID=<pid> LOG=<path.ndjson> META=<path.json>; then tail LOG
```
Direct form (blocks until done):
```powershell
grok --cwd '<cwd>' -r '<session_id>' --prompt-file '<prompt.txt>' --always-approve --no-auto-update --output-format streaming-json
```
Read `streaming-json` by switching on `type`:
- `text` / `thought`: response / reasoning chunks (`data`)
- `tool_call` (`toolName`, `title`, `kind`, `rawInput`) → `tool_call_update` (`status`, `rawOutput`)
- `plan` (`entries`), `usage` (per model response), `max_turns_reached`, `auto_compact_*`
- `end`: last line, with `stopReason` (`end_turn`, `max_tokens`, `max_turn_requests`, `refusal`, `cancelled`), `sessionId`, spend
- `error`: `message`, non-zero exit
Treat unknown types as non-fatal. If a line has no `type` but carries ACP `sessionUpdate`, map `agent_message_chunk`→text, `agent_thought_chunk`→thought, and the rest by name.

Post **sparse** milestones (tool started/finished, plan changes), not every chunk. Exit codes: 0 ok, 1 error, 130 SIGINT, 143 SIGTERM; a force-kill shows as 1 or -1.

## 3) Stop / interrupt
`grok-interrupt.ps1 -SessionId <id>` kills the matching **headless** grok process **and its child tree** (tool shells), so builds don't linger. It never touches TUIs unless `-IncludeTui` is passed explicitly. Session state is kept up to the last completed tool call; file edits are not rolled back. Resume later with `-r <id> -p "continue"`. In multi-bot mode the chief forwards stop to the owning worker.

(Grok's ACP interface supports targeted per-response cancel for SDK clients; the CLI bridge uses process stop.)

## 4) After-turn pack
`grok-after-turn.ps1 -Cwd <cwd> -SessionId <id> -SinceIso <turn start>` → reply text (from `end`/json), **new images** CopyToBox'd into chat, git branch/diffstat, `last_turn_summary`, optional `grok usage <id>` spend.

## Bidirectional media
- **Out:** new files in `…/images/` and `…/assets/` (plus project outputs) → CopyToBox → show in chat.
- **In:** chat attachment → CopyFromBox to `<cwd>\.grok-bridge-in\` (or `~\.grok-bridge\in\`) → pass as a content block:
  `--prompt-json '[{"type":"text","text":"<ask>"},{"type":"image","mimeType":"image/png","data":"<base64>"}]'`
  `grok-turn.ps1 -Images <paths>` builds this. Windows command lines cap near 32k chars, so large images fall back to a text block naming the staged path for grok to open.

## Chief ↔ worker protocol (when multi-bot is on)
```text
RGB_DISPATCH
cwd: <path>
session_id: <uuid|NEW|ASK>
intent: <ask>
flags: stream=1 always_approve=1 fork=0 model=<id|default> effort=<lvl|default> max_turns=<n|none>
images: <staged paths|none>
```
```text
RGB_RESULT
cwd: …
session_id: …
status: ok|error|stopped|max_turns
stop_reason: end_turn|cancelled|…
summary: …
images: …
git: …
usage: <tokens/cost if reported>
```
Optional: `RGB_PROGRESS <milestone>`

## Controls / session ops / optional extras
Model/effort (`-m`, `--effort`), fork vs append (`--fork-session`), worktree turns (`-w`), pins, `grok export`, `grok usage`, desktop screenshot, done ping.

## Do not
- Require workers or a channel for simple one-project use
- Create channels or workers speculatively, or fan out without a clear ask
- Require a live hold before resuming idle sessions
- Use `-s` to resume (it only creates); use `-r`/`-c`
- Kill TUIs or match grok by process name alone; kill only the headless PID tree you started
- Run `grok update`, `grok sessions delete`, `grok logout`, or `grok worktree rm` unasked
- Use public tunnels or relays; hide idle sessions; leave images on disk only; paste grok secrets; use Cursor CloudAgent for this
