# Changelog

## v9 · plugin 0.4.5 · 2026-10-23
Re-verified against **Grok Build `grok 1.0.69`** (alpha and enterprise; npm published 2026-10-23 02:07 UTC). 1.0.68 was alpha-only (2026-10-22 15:24 UTC); stable is still 1.0.67. Checked by diffing the 1.0.67, 1.0.68 and 1.0.69 Linux builds from npm: short and full help, `grok help <sub>` for every subcommand, the bundled user guide, and the official release notes. **Not live-tested on Windows yet**: the test PC still had 1.0.66 installed (alpha, auto-update on, `updateAvailable` true, latest 1.0.69).

- **Nothing bridge-breaking.** Resume (`-r`/`-c`/`-s`/`--fork-session`), output formats, streaming event names, prompt/image input, `--add-dir` (still refused with `-r`/`-c`) and the `~/.grok` session layout are unchanged. `--no-auto-update` and `--background-wait-timeout` still parse.
- **New hidden headless flag `--background-shell-timeout <secs>` (1.0.68):** stops only lingering background shells after the latest turn, keeps waiting on subagents, and doesn't fail the run. Daemon route only (otherwise grok exits with an error) and it can't be combined with `--background-wait-timeout`. Documented in the cheat sheet; `grok-turn.ps1` does not pass it.
- **Auto-update safety (1.0.68):** running sessions no longer break when an update deletes their binary. Noted under the auto-update gotcha; the bridge keeps passing `--no-auto-update`.
- **Daemon route resume (1.0.68):** a session ID also finds a session held at the same place in the repo's main checkout or a `grok -w` worktree.
- **`--add-dir` permissions (1.0.69):** an added folder applies its own `deny`/`ask` rules but not its `allow` rules or `defaultMode`, so it can only make the session stricter.
- **Other changes (not bridge):** `[keys] vim = "off"|"nav"` replaces `[ui] vim_mode`, `[ui] simple_mode` is retired (`grok doctor` flags both); dashboard `/resume` lists sessions from every folder; TUI image placeholders now show whether each image was sent; faster quit; `--oauth` help reworded; `grok worker` gains Cursor Self-Hosted Pool options (`--pool`, `--label(s-file)`, `--api-key`, `--auth-token-file`, `--single-use`, `--pool-name`, `--mint-github-token`, `--sync-dashboard-secrets`, `--on-session-start/-end`).
- `grok-mission-control.ps1` default `-VerifiedVersion` is now 1.0.69. Template v9 still staged (not public yet).

## v9 · plugin 0.4.4 · 2026-10-22
Re-verified against **Grok Build `grok 1.0.67`** (stable, alpha and enterprise all point to it; npm published 2026-10-21 17:21 UTC). **This is the first stable release past 1.0.62**, so stable users jump straight from 1.0.62 to 1.0.67 and get every 1.0.63–1.0.66 change noted in the entries below at once (two-level help, real headless plan mode, CJK title matching, `grok worker`). Checked by diffing the 1.0.67 and 1.0.66 Linux builds from npm: full `grok help` / `--help`, `grok help` for `agent`, `sessions`, `sessions list`, `export`, `update`, `usage`, `leader`, `worker`, `models`, `worktree`, `mcp`, and the bundled user guide. **Not live-tested on Windows yet**: the test PC still had 1.0.66 installed (alpha, auto-update on, `updateAvailable` true).

- **Nothing bridge-breaking.** Resume (`-r`/`-c`/`-s`/`--fork-session`), output formats, streaming event names, prompt/image input and the `~/.grok` session layout are unchanged. `--no-auto-update` and `--background-wait-timeout` still parse.
- **New flag `--add-dir <DIR>`** (repeatable): a new session can also work in extra folders beside `--cwd` (relative paths start from the working directory; refused for untrusted folders). It **cannot be combined with `-r`/`-c`** (exit 2); a resumed session keeps the folders it was created with. Added to the cheat sheet; `grok-turn.ps1` does not pass it (unchanged).
- **Other changes (not bridge):** Tab / → accept a prompt suggestion in the TUI; worktrees now also inherit the main checkout's saved "always allow" answers (`[features] worktree_inherits_main_approvals`, default on); the session-end Stop hook runs alongside `SessionEnd` for at most 1.5 s; new config `features.ask_answer_rows`; telemetry gains `release_line` / `release_channel` attributes.
- `grok-mission-control.ps1` default `-VerifiedVersion` is now 1.0.67. Template v9 still staged (not public yet).

## v9 · plugin 0.4.3 · 2026-10-21
Re-verified against **Grok Build `grok 1.0.66`** (alpha and enterprise, published 2026-10-20 22:33 UTC; 1.0.65 came out 19:35 UTC the same day; stable still 1.0.62). Checked by diffing the 1.0.66 and 1.0.64 Linux builds from npm: full help, `agent`/`sessions`/`export`/`update`/`leader`/`worker` help, the bundled user guide (`~/.grok/docs/user-guide`) and built-in strings. **Not live-tested on Windows yet**: the test PC still had 1.0.63 installed (alpha, auto-update on, `updateAvailable` true).

- **Nothing bridge-breaking.** Flag set, headless, `-r`/`-s`/`--fork-session`, output formats, streaming event names and the `~/.grok` session layout are unchanged. `--no-auto-update` and `--background-wait-timeout` still parse.
- **Help is now two-level.** `grok --help` and `grok <sub> --help`/`-h` print a short summary; the full descriptions moved to `grok help` and `grok help <sub>`. The skill's drift check and the self-update routine now re-read `grok help …` (plus the bundled user guide) instead of `--help`.
- **Headless plan mode is real now.** `grok -p --permission-mode plan` holds plan mode for the whole run (also when resuming or forking): only the plan file can be edited and other edits are refused with exit code 0. Noted in the cheat sheet. On the daemon route a turn that keeps a plan may send one follow-up "build the plan" turn, and the `json` result's `usage` then covers both turns.
- **Title matching:** `-r <title>` and the session picker match Chinese/Japanese titles by words that start inside a title word.
- `grok cursor-worker` is hidden from help (`grok worker` remains); both added to the "Do not ... unasked" list.
- `grok-mission-control.ps1` default `-VerifiedVersion` is now 1.0.66. Template v9 still staged (not public yet).

## v9 · plugin 0.4.2 · 2026-10-20
Re-verified against **Grok Build `grok 1.0.64`** (alpha, published 2026-10-19 22:52 UTC; stable/enterprise still 1.0.62). Checked by diffing the 1.0.64 and 1.0.63 Linux builds from npm: `--help`, `agent`/`sessions`/`export`/`update`/`leader` help, and built-in strings. **Not live-tested on Windows yet**: the test PC still had 1.0.63 installed (alpha, auto-update on, `updateAvailable` true). Helpers unchanged apart from the default below.

- **Nothing bridge-breaking in 1.0.64.** Headless flags, `-r`/`-s`/`--fork-session`, output formats, streaming event names and the `~/.grok` session layout are unchanged. `--no-auto-update` and `--background-wait-timeout` still parse though not in `--help`.
- **New:** `grok worker start|stop|status` (also `grok leader worker`) registers the PC as a Cursor private worker for Cloud Agents. Added to the skill's "Do not ... unasked" list; the bridge never uses it.
- **Other changes seen in built-in text (not bridge):** hook-trust hints reworded ("Trust the folder first"), subagent/workflow steps that ask for worktree isolation run in the session's folder instead, and worktree requests that can't be met refuse cleanly.
- `grok-mission-control.ps1` default `-VerifiedVersion` is now 1.0.64 (a PC still on 1.0.63 prints `DRIFT=older` until auto-update installs 1.0.64). Template v9 still staged (not public yet).

## v9 · plugin 0.4.1 · 2026-10-18
Re-verified against **Grok Build `grok 1.0.63`** (alpha, 2026-10-17; stable/enterprise still 1.0.62), now installed on the Windows test PC. This is the live retest v9 was waiting for: new headless turn, resume by UUID, `json` and `streaming-json` output, `grok-turn.ps1` → `grok-interrupt.ps1` mid shell command (grok and its tool shell both stopped), `grok-after-turn.ps1`, and mission-control drift. Helpers work unchanged.

- **Nothing bridge-breaking in 1.0.63.** Its changes are memory (always the concise `MEMORY.md` index; `[memory_v2] compact_index_enabled` no longer has an effect), per-session/subagent Rex status records, `grok worktree list/show` repair hints, command hooks with an `args` list (no shell), `/fork` keeping `-m`/`--effort`, plan-review input fixes, and custom Chat Completions models with MCP.
- **Cheat sheet:** `json` output also carries `requestId`, `thought` and `total_cost_usd_ticks`; `streaming-json` line types seen: `text`, `thought`, `tool_call`, `tool_call_update`, `usage`, `available_commands`, `end`. `-r` help now says a sole renamed match wins among duplicate titles, otherwise resume fails as ambiguous. `--no-auto-update` and `--background-wait-timeout` are still accepted though not in `--help`.
- `grok-mission-control.ps1` default `-VerifiedVersion` is now 1.0.63. Template v9 still staged (not public yet).

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
