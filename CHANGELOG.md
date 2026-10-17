# Changelog

## v9 · plugin 0.4.0 · 2026-10-17
Brought up to date with **Grok Build `grok 1.0.62`** (stable/alpha/enterprise channel pointers 2026-10-16). Updated from public release notes, npm `@xai-official/grok@1.0.62`, and `grok update --check --json` on Tudorbox. **Not live-retested on 1.0.62 yet** — Tudorbox still had 1.0.55 installed (alpha, auto-update on) when this landed; helpers are unchanged pending that install.

- **Resume (bridge-relevant):** `-r` / `/resume` title matching ignores word separators and word order (1.0.59–1.0.62); an exact single ID/title match opens directly instead of always opening the picker (1.0.61+); a miss reports immediately / suggests similar titles instead of trying remote restore (1.0.60). Scripts should still pass the UUID.
- **Headless:** `grok -p` now also waits for the follow-up turn a finished background task starts before exiting (1.0.62). `--background-wait-timeout` that stops pending work exits with an **error** instead of success. Existing `grok-turn.ps1` PID waits already cover the longer exit.
- **TUI-only (not bridge):** resume picker search, dashboard peek text selection, workflow roster scroll, Windows hook spawn error text — noted, no helper changes.
- `grok-mission-control.ps1` default `-VerifiedVersion` is now 1.0.62. Template v9 staged (not public yet).

## v8 · plugin 0.3.0 · 2026-10-14
Re-verified against **Grok Build `grok 1.0.55`** (alpha channel; stable was 1.0.52). Live test on Windows: new turn, resume, `--prompt-json` image in, interrupt mid-shell-command, after-turn pack, mission control. Helpers work unchanged.

- **Result / `end` line:** now also carries `cwd` (the folder actually used, including a `-w` worktree) and `total_cost_usd` (+ `total_cost_usd_ticks`); `modelUsage` has per-model `costUSD`.
- **Flags:** `--no-auto-update` and `--yolo` no longer appear in `--help` but are still accepted (checked on 1.0.55). `--allowed-tools`/`--allowedTools` alias `--allow`; `--disallowedTools` aliases `--deny`; `--disallowed-tools` takes model-facing names (`run_terminal_command`, `spawn_subagent`). New in help: `--verbatim`, `--json-schema`, `--disable-web-search`, `grok du`.
- **Headless:** `grok -p` waits for background goals and reports their outcome (1.0.51); `--background-wait-timeout` caps it (release notes only). Prompt files with a byte-order mark work (1.0.52).
- **Interrupt:** grok now stops its own shell commands when it quits or gets a signal (1.0.52); re-verified that `grok-interrupt.ps1` leaves no grok or tool process and no `end` line.
- **Sessions:** `grok sessions list`/`/resume` include worktree sessions from the same subfolder (1.0.51); `-w -r` forks run in the worktree path (1.0.54); a corrupt `active_sessions.json` is backed up and salvaged (1.0.54). Storage map adds `chat_history.jsonl`, `prompt_context.json`, `rewind_points.jsonl` and their `.lock` files.
- **Export:** `grok export <id> <out>` refuses to overwrite an existing file (1.0.52). `/share` and session sharing were removed (1.0.51).
- `grok-mission-control.ps1` default `-VerifiedVersion` is now 1.0.55. Template v8 staged (not public yet).

## v7 template staged · 2026-10-08
- Grok Bot template v7 is **staged for publishing (not public yet)**; the public link still serves v6. Contents: `docs/TEMPLATE.md`.
- New first-run skill `skills/rgb-getting-started/SKILL.md`: pick the linked PC, check grok and sign-in, install helpers with consent, pin a project, run the drift check, and make sure exactly one self-update routine exists.
- New `routines/grok-build-self-update.md`: the template's daily routine (name, schedule, verbatim job text, guarantees).
- Skill synced to the saved v7: the daily watch now says "your routine tool" instead of naming a specific tool; the helper list mentions version drift, PID-based interrupt, and the after-turn state/reply text.

## v7 (live-test fixes + self-update) · 2026-10-08
- **Stay current (self-update):** new skill section. A drift check on every use compares `grok --version` with "Verified against"; when it's newer the bot re-reads `--help`, adapts (help wins), rewrites its own skill copy, and bumps the version. On first setup the bot creates one daily routine that watches for releases (`grok update --check --json`, read-only) and re-derives the cheat sheet. It may point the owner at this repo when its copy has moved past the published template. Never runs `grok update`, never touches live sessions.
- `grok-mission-control.ps1`: `-VerifiedVersion` / `-CheckLatest`, prints `DRIFT=…`, adds `version_drift` to the JSON.
- Live test on grok 1.0.50 confirmed: background turns survive the launching command; `streaming-json` is type-tagged; `end` carries `stopReason` + `sessionId`; `-r` resumes the same session; `--prompt-json` image blocks work; interrupt kills grok plus the tool/MCP child tree and leaves TUIs alone.
- `grok-after-turn.ps1`: `-Meta` input; finds the last `end` line instead of the last line (an interrupted turn has none → `STATE=stopped(no end line)`); derives the session id for new sessions; skips this turn's inbound images (`--prompt-json` images are stored in `assets/`); returns reply text.
- `grok-turn.ps1`: META records inbound image SHA-256; `-Wait` reports the real `end` line or `END|none`.
- Skill: real stream shapes (repeated `available_commands`, shell updates resend the full output, tool names `write`/`run_terminal_command`), poll instead of `-Wait`, no `end` line after a force stop.

## v7 · plugin 0.2.0 · 2026-10-08
Brought up to date with **Grok Build `grok 1.0.50`** (from the ~1.0.40-era CLI that v6 targeted).

- **Streaming:** `streaming-json` documented as grok's native NDJSON (`text`, `thought`, `tool_call`, `tool_call_update`, `plan`, `usage`, `end`, `error`); `streaming-messages-json` (+ `--include-partial-messages`) noted as the Messages-API-shaped alternative. `json` result now carries `usage` / `num_turns` / `modelUsage`.
- **Sessions:** `-s/--session-id` now only *creates* a session with a fresh UUID (it no longer resumes or upserts); resume with `-r` (ID or case-insensitive title in the current dir) or `-c`. `--fork-session` branches instead of appending.
- **Discovery:** `grok sessions list|search -n` noted (scoped to the current directory); mission control still scans `~/.grok/sessions` for the all-folders view. Storage map updated (`events.jsonl`, `usage.json`, `terminal/`, `compaction/`, richer `summary.json` fields).
- **Prompts & media:** `--prompt-file` for long/quoted prompts; `--prompt-json` image content blocks for chat attachments, with a path fallback past the Windows command-line limit.
- **Controls:** `--permission-mode`, `--effort` levels, `--max-turns`, `--no-auto-update`, `grok usage`, `grok update --check --json`.
- **Auto-update gotcha:** a self-update renames a running TUI's binary to `grok.exe.old`; helpers now match by PID and flag "old binary" LIVE rows.
- **Helpers:** new `grok-turn.ps1` (background turn + NDJSON log, `-DryRun`, `-Wait`); `grok-interrupt.ps1` kills only headless turns plus their child tree, refuses with no target, and supports `-ProcessId`; `grok-mission-control.ps1` adds RUNNING headless rows, version, last-turn summary/effort/branch, and creates its output folder; `grok-after-turn.ps1` finds sessions by id, skips git outside repos, and reads the turn's `end` line.
- **Protocol:** `RGB_DISPATCH` gains `fork`, `model`, `effort`, `max_turns`, `images`; `RGB_RESULT` gains `stop_reason`, `usage`.

## v6 · plugin 0.1.0 · 2026-09-16
Initial public release: mission control, streaming, interrupt, after-turn packs, bidirectional media, optional chief → workers and RGB channel.
