---
name: Remote Grok Build
description: >-
  Use this when bridging Grok Bot chat to local Grok Build (the grok CLI) on a
  linked Windows PC: mission control, streaming turns, interrupt, media packs;
  optionally suggest chief→per-project workers and an RGB channel for parallel
  work.
---
# Remote Grok Build bridge (template v9)

Drive **local Grok Build** (`grok`) on a registered user computer from Grok Bot chat: mission-control cockpit, same-session resume, live streaming, interrupt, bidirectional media.

**Verified against:** `grok 1.0.81` (alpha, published 2026-11-11 05:44 Berlin; npm `latest` still 1.0.77). 1.0.81 was checked on 2026-11-11 by diffing the 1.0.80 and 1.0.81 Linux builds from npm: short and full help, `<sub> --help` for every subcommand (and second-level subcommands), the bundled user guide and the binary's env-var/config strings. Nothing bridge-breaking: resume (`-r`/`-c`/`-s`/`--fork-session`), output formats, streaming event names, prompt/image input, `--add-dir`, interrupt/`cancelled` handling and the `~/.grok` session layout are unchanged; `--no-auto-update` and `GROK_DISABLE_AUTOUPDATER` still parse. Only CLI help change: **`grok sessions list --all`** includes sessions from every folder and repository, not only the current one (`sessions search` has no `--all`); without it, the list notes how many cloud sessions from other folders it hid. Changes worth knowing: on the daemon route `-s/--session-id` must be a **lowercase hyphenated UUID** (an uppercase GUID is refused), so lowercase any generated id; `storage.cleanup_ttl_days` is now documented as shell-route only (the daemon route never cleans up its sessions under `~/.grok`); `features.resume_refusals` no longer repeats a commit-based refusal until HEAD moves. Otherwise not bridge: new `features.cloud_agents` (default on, `GROK_CLOUD_AGENTS`; off refuses sending a checkout/session to cloud agents), opt-in daemon-route `/tree` (`features.history_tree`, `GROK_HISTORY_TREE`), `features.fail_silent_opens` (default off), `features.cursor_relay_login` (Cursor-signed-in leaders), `features.sign_in_chooser` replaces `features.cursor_api_key_paste`, `auth.force_cursor_sign_in` (Cursor builds), `features.auto_review_protected_paths` now covers the daemon route too, dashboard "cancel turn and move" prompt. Previously, 1.0.80 was checked on 2026-11-10 by diffing the 1.0.79 and 1.0.80 Linux builds from npm: short and full help, `grok help <sub>` and `<sub> --help` for every subcommand (and second-level subcommands), the bundled user guide and the binary's env-var/config strings. Nothing bridge-breaking: CLI help for every subcommand is identical to 1.0.79; resume (`-r`/`-c`/`-s`/`--fork-session`), output formats, streaming event names, prompt/image input, `--add-dir`, interrupt/`cancelled` handling, the `~/.grok` session layout and the headless and sessions guide pages are unchanged; `--no-auto-update` and `GROK_DISABLE_AUTOUPDATER` still parse. Changes worth knowing: the **interactive TUI now defaults to Auto-review** (`auto`) instead of ask (`default`); headless `-p` is unaffected and the bridge's `-PermissionMode` still passes `--permission-mode` explicitly; on the daemon route, new `features.ask_local_reads` (default on, `GROK_ASK_LOCAL_READS`) lets Ask mode run local read-only shell commands such as `stat`, `find` and `du` with no approval prompt, so `default`-mode turns see fewer prompts; ACP `yoloMode`/`autoMode` are now also accepted on `session/load` and `session/resume` (and `yoloMode: false` on a load of a running session turns always-approve off); new `features.overdue_reattach` (daemon route, default on, `GROK_OVERDUE_REATTACH`) keeps a session open and reattaching for up to 10 minutes when its journal stops answering but the background service still listens. Otherwise not bridge: `/auto-review` (`/auto` still runs); opt-in `features.pending_steer` (`GROK_PENDING_STEER`) shows a message sent mid-turn as pending; opt-in `features.paged_full_load` (`GROK_PAGED_FULL_LOAD`); shell-route `features.auto_review_protected_paths` (`GROK_AUTO_REVIEW_PROTECTED_PATHS`, default off); debug `GROK_FPS`/`GROK_SCROLL_DEBUG`; more vim-mode keys. 1.0.79 (2026-11-08 check) by diffing the 1.0.78 and 1.0.79 Linux builds from npm: short and full help, `grok help <sub>` and `<sub> --help` for every subcommand (and second-level subcommands), the bundled user guide and the binary's env-var/config strings. Nothing bridge-breaking: resume (`-r`/`-c`/`-s`/`--fork-session`), output formats, streaming event names, prompt/image input (`--prompt-file`/`--prompt-json`), `--add-dir`, interrupt/`cancelled` handling and the `~/.grok` session layout are unchanged; `--no-auto-update` and `GROK_DISABLE_AUTOUPDATER` still parse; top-level help is identical to 1.0.78 (only `grok leader worker` / `grok worker` help text changed, for Cursor workers). Changes worth knowing: on the **daemon route** a model response that called tools now ends with an extra `usage` line **before** its tool calls whose counts are 0, and the turn still ends with one carrying the turn's total, so skip zero-count `usage` lines and keep reading spend from `end`; a **workflow run is no longer background work a headless run waits for** (either route): the run exits once the first turn and other background work end, a still-running workflow's result never reaches the output, a workflow run's outcome no longer changes the exit code or gets a stderr line, and `--no-wait-for-background` on the daemon route no longer lists what exit stopped; new `features.unified_session_import` (default on, `GROK_UNIFIED_SESSION_IMPORT`) lets `--resume <id>` open a session from Grok's unified build as a new **native copy** (a different session id; `-c` sees only native sessions); new opt-in `features.resume_refusals` (`GROK_RESUME_REFUSALS`, default off) names the pid of the other Grok window holding a session when a load is refused; the updater now recognizes npm-launched installs (`GROK_MANAGED_BY_NPM`) and repairs a config that recorded `npm` for a build under `~/.grok/downloads` (back to `internal`). Otherwise not bridge: `/rename --auto`; `[keys] vim = "all"` documented with `/vim-mode all`; Linux-only `features.proc_protection` / `GROK_PROC_PROTECTION`; link-URL hiding rollout (`ui.link_urls`, `GROK_LINK_URL_HIDING`/`GROK_LINK_URLS`; replaces 1.0.78's `GROK_LINK_CARD`); `features.cursor_api_key_paste`; `GROK_OTEL_SHUTDOWN_TIMEOUT_MS`; macOS `Ctrl+V` screenshot paste; a worktree at a Windows `\` path no longer inherits the main checkout's "always allow" answers; `grok leader worker` is now the in-leader Cursor worker door (agent-host builds default `grok worker` to Cursor's TypeScript engine). 1.0.78 (2026-11-06 check) by diffing the 1.0.77 and 1.0.78 Linux builds from npm: short and full help, `grok help <sub>` and `<sub> --help` for every subcommand, the bundled user guide and the binary's env-var/config strings. Nothing bridge-breaking: resume (`-r`/`-c`/`-s`/`--fork-session`), output formats, streaming event names, prompt/image input (`--prompt-file`/`--prompt-json`), `--add-dir`, interrupt/`cancelled` handling and the `~/.grok` session layout are unchanged; `--no-auto-update` and `GROK_DISABLE_AUTOUPDATER` still parse; CLI help for every subcommand is identical to 1.0.77. What changed in 1.0.78 is TUI-only: `@` file chips can be edited in place; typed `@~/` paths resolve to the home folder; dragging in the transcript selects and copies colored text across message blocks instead of whole blocks; always-approve help text now correctly says the setting is saved to config. Bundled-guide extras also TUI-only (`features.link_card` / `GROK_LINK_CARD` for clickable link cards; cancel-turn panel choices when subagents are running; line-viewer on picked `@` files). 1.0.75–1.0.77 (2026-11-05 check): headless spend (`end`'s `usage`/cost and `streaming-messages-json`'s `result.usage`) now sums **every turn the run made**, including later wake or goal turns, so never add the per-response `usage` lines to it; on the daemon route a `usage` line is sent once per turn (subagent turns included) with only that turn's total, a later turn's `text` (such as a wake turn's reply) gets no paragraph break of its own, and `usage_is_incomplete` (with cost omitted) is also set when a later turn was interrupted or failed, a goal was still running at exit, or exit couldn't stop work after a signal; after `--no-wait-for-background` or a background wait that runs out, the daemon route lists on stderr each workflow run it stopped. Update channels: 1.0.75 and 1.0.76 showed `grok update --legacy-alpha`/`--legacy-stable` (also `--channel legacy-alpha`/`legacy-stable`), which switch to the native build, save `build = "legacy"` in `~/.grok/config.toml` and keep the PC off a server-side "unified" build rollout (`--channel unified-alpha`/`unified` returns); 1.0.77 hides those flags from help and offers them only to accounts in that rollout, so an alpha PC may one day be moved to the unified build by auto-update (the bridge still never runs `grok update`). Otherwise not bridge: `grok usage` without a session ID prints your plan's usage limit (`--json`; daemon route only, the shell route says to use `/usage`), and `grok usage <session>` is unchanged; `grok wrap` opens web links from grok over SSH in the local browser (`GROK_WRAP_OPEN_LINKS=0` turns it off); `ui.kitty_keyboard = "query"` / `GROK_KITTY_KEYBOARD` can ask Windows Terminal for Kitty keyboard support; `cursor_worker.engine` (`rust`/`typescript`) for `grok worker`; `features.daemon_feedback_drafts`; server campaigns can turn experiments off per account (`disabled (remote_opt_out)`); `subagents.max_depth` default 1 (also `GROK_SUBAGENTS_MAX_DEPTH`); program-status reports in Herdr 2. 1.0.74 (2026-11-03 check): a headless run stopped by a *graceful* SIGINT/SIGTERM after its prompt was sent now stops its background work (up to ~10 s), then ends `streaming-json` with an `end` whose `stopReason` is `cancelled` (empty `requestId`, `usage_is_incomplete: true`, usage a lower bound), or `error` after a failed prompt; `json` gets `stopReason: cancelled`; a second signal forces the exit (the bridge's `grok-interrupt.ps1` force-kills with `taskkill /F`, so its stops still write no `end` line); under any `--sandbox`/`GROK_SANDBOX` profile except `off` grok never starts an update on its own (it only notifies; `grok agent` prints the notice on stderr); `grok export` now prints agent messages under `## Sent message to <subagent> · <delivery>`, `## <subagent> sent a message` and `## <a> sent a message to <b> · <delivery>` headings instead of 1.0.71's `## you → …`; on the daemon route a TUI `grok --resume`/`-c` that finds no session now stays open in a new session with the picker (interactive only); new `features.resume_pagination` / `GROK_RESUME_PAGINATION` (TUI loads a resumed session's newest turns first, default off). Otherwise not bridge: `grok bedrock status` (Amazon Bedrock models on your own AWS account); `@` file picker can reach `/`, `~/`, `../` paths (`ui.at_picker_outside_workspace`); `/btw` panel `[Copy]` and `Ctrl+O` open-session; quote `[Copy]` buttons; model ids with a dot must be quoted in TOML (`[model."grok-4.6"]`); `workflows.runtime` (`node`/`deno`, daemon route); `model.<id>.interjection_reply_nudge`; `AgentMessage(...)` permission rules; experiments gain `GROK_DISABLE_EXPERIMENTS` / `[experiments] enabled = false` and `experiments.exclude` (shown as `disabled (env_opt_out)` / `excluded` in `grok inspect`); campaigns/experiments can turn Auto mode off but never on; the Kitty keyboard protocol is used on xterm.js 6.1.0-beta.219+ terminals (VS Code/Cursor/Windsurf; not on Windows). 1.0.73 (2026-10-29 check): on the native route a folder search with the grok toolset's `grep` now leaves out files a `Read`/`Grep` ask rule's path covers instead of asking (this replaces 1.0.72's extra prompts; headless turns with rules like `Read(**/.env)` see fewer prompts but those files are silently skipped; a pathless rule such as `Grep` or `Read(*)` still asks before every search; daemon route and compatibility `grep` unchanged); a leading `~/` in a permission pattern now means the home directory (`Read(~/.ssh/**)`); new `[ui] multiline_default` (Enter inserts a newline, Shift/Alt+Enter sends) only affects the interactive TUI, not `-p` turns. Otherwise not bridge: GruvboxDarkHard theme; `managed_mcps.allow_external_auth`; the root transcript shows messages between two subagents; PageUp/PageDown/Home/End in plugin lists. 1.0.72 (2026-10-28 check): on the daemon route a session ID also resumes a session an earlier Grok or the Cursor CLI saved in the same checkout or `grok -w` worktree; a recursive grep now asks for permission when its walk can reach a file a `Read`/`Grep` ask rule covers (a session with rules like `Read(**/.env)` may see more permission prompts in headless turns); new requirements-only `features.writeback` pin keeps sessions local. Otherwise not bridge: plan-review typing (`a` always types in the prompt), MCP file-form schemas only for trusted xAI base URLs, `cli.session_registry` can be pinned. 1.0.71 (2026-10-27 check): `grok export` now prints messages between agents under `## you → <subagent>` / `## <subagent> → you` headings (with a status when a send didn't land), so exported transcripts of sessions that used subagents look slightly different; an update-channel experiment arm is now a temporary override that `grok update --stable/--alpha/--enterprise/--channel` leaves (recorded in `~/.grok/experiments_state.json`), and the first `grok update` on 1.0.71 may record such dismissals, which the bridge never triggers because it never runs `grok update`. Otherwise not bridge: the daemon route's code-cell tool is now spelled `Execute`; hooks gain `failClosed` (`PreToolUse`/`UserPromptSubmit`); `[keys] vim = "all"` adds experimental vim editing in the prompt; `ui.single_ctrl_c_quit`; `GROK_INPUT_LOG` key logging; `grok worker` gains `--run-mcp-servers`, `--mcp-tool-timeout`, `--data-dir` and `--wait` (Cursor pools). 1.0.70 (2026-10-24 check): first stable past 1.0.67. Its bridge change: a new env var `GROK_UPDATE_CHANNEL` (`stable`/`alpha`/`enterprise`) pins the update channel over `[cli] channel`, and while it's set `grok update --stable/--alpha/--enterprise/--channel` refuse to switch; `GROK_DISABLE_EXPERIMENTS=1` (or `[experiments] enabled = false`) turns off server experiments, which could otherwise change the channel. Otherwise not bridge: `grok worker` gains `controller`, `--clone-git-repos`, `--identity-socket`, `--management-addr`, `--idle-release-timeout` (Cursor Self-Hosted Pools); execute cells can call MCP tools via `host.mcp` on the daemon route; plugins skip skills that symlink outside the plugin folder (and, on Windows, skill paths over 260 characters); team admins can opt a team out of coding-data sharing. 1.0.68 and 1.0.69 (2026-10-23 check): 1.0.68 adds a hidden headless `--background-shell-timeout <secs>` (daemon route only, see the cheat sheet; the bridge does not use it), and running sessions no longer break when an auto-update deletes their binary; 1.0.69 makes an `--add-dir` folder apply its own `deny`/`ask` rules (never its `allow` rules), so an added folder can only make a session stricter; `[keys] vim` (`off`/`nav`) replaces `[ui] vim_mode` and `[ui] simple_mode` is retired (`grok doctor` flags both). 1.0.67 (2026-10-22 check) added `--add-dir <DIR>` (repeatable, new sessions only). 1.0.65–1.0.66 (2026-10-21 check): `grok --help` and `<sub> --help`/`-h` print a **short summary**, the full text is `grok help` / `grok help <sub>`; headless `--permission-mode plan` really holds plan mode for `grok -p`; `-r` title matching handles Chinese/Japanese titles; `grok cursor-worker` is hidden (`grok worker` remains). Last live test on Windows was 1.0.63 on 2026-10-18: new headless turn, resume by UUID, `json` and `streaming-json` output, `grok-turn.ps1` → `grok-interrupt.ps1` mid shell command, `grok-after-turn.ps1`, mission-control drift. A PC still on 1.0.62–1.0.80 (stable is 1.0.77) shows `DRIFT=older`; that is harmless, and alpha PCs pick up 1.0.81 through grok's auto-update. The test PC was offline on 2026-10-27 and 2026-10-28; on 2026-10-29 it was online but still on 1.0.72, on 2026-11-03 it was on 1.0.73 (1.0.74 pending on alpha with auto-update on), on 2026-11-05 it was offline, on 2026-11-06 it was online on 1.0.77 with 1.0.78 pending on alpha, and on 2026-11-08 it was online on 1.0.78 with 1.0.79 pending on alpha (auto-update on; only read-only `grok --version`, `grok update --check --json` and `grok --help` were run, and its help matched 1.0.79's), on 2026-11-10 it was online but still on 1.0.78 with 1.0.80 pending on alpha (auto-update on; only read-only `grok --version` and `grok update --check --json` were run), on 2026-11-11 it was online but still on 1.0.78 with 1.0.81 pending on alpha (auto-update on; only read-only `grok --version` and `grok update --check --json` were run), so 1.0.71–1.0.81 are not live-tested on Windows. v9 first targeted 1.0.62 from release notes only, v8 1.0.55, v7 1.0.50, v6 the ~1.0.3x/1.0.40 CLI. Before using the cheat sheet, run the drift check in **Stay current** below.

**Optional (suggested at scale):** chief → per-project worker bots, plus an optional shared channel for them.

## When this applies
- Remote control of local Grok Build / Grok CLI on a linked PC
- `status`, pick a project/session, send a turn, stop a turn, shuttle images
- Growing to several projects without one thread's context turning to mush

Not for Cursor cloud agents. Access is through the **Grok Bot computer link only** (authenticated home access, no public tunnels, no Cloudflare/ngrok, no `grok agent headless`/`serve` relays).

## Stay current (self-update)
This skill keeps itself current; nobody has to say "update".

1. **Drift check on every use.** Before the first turn in a conversation, and whenever `status` runs, compare the linked PC's `grok --version` with **Verified against** above (mission control prints `DRIFT=none|newer|older`; pass `-VerifiedVersion <that version>`). If the installed grok is **newer**:
   - Re-read the **full** help: `grok help` and `grok help <sub>` for the subcommands you're about to use (`grok help sessions`, `grok help sessions list`, `grok help export`, `grok help usage`, `grok help update`), plus `~/.grok/CHANGELOG.md` (release notes for the installed version) and, when needed, the bundled guide under `~/.grok/docs/user-guide/` (e.g. `14-headless-mode.md`, `17-sessions.md`). Since 1.0.65–1.0.66, `--help`/`-h` only print a short summary; on older builds `--help` is still the full text.
   - Adapt this turn's commands. **Help output wins over the cheat sheet.**
   - Rewrite your own copy of this skill with your skill tool (same skill id): fix the cheat sheet, bump **Verified against** to the installed version with today's date, keep everything else. If a helper under `~/.grok-bridge/` broke because of the change, fix that local copy too and say so.
   - Tell the owner in one or two lines what changed.
2. **Daily watch.** On first setup, if you don't already have one, create **one** daily routine for yourself with your routine tool, at a quiet hour in the owner's timezone. Each run:
   - On the linked PC, run `grok --version` and `grok update --check --json` (`--check` is read-only).
   - If the installed version is newer than **Verified against**, run the re-derive steps from (1): help → cheat sheet → rewrite the skill → tell the owner what changed (new/removed/renamed flags, output-format changes, session-layout changes).
   - If only `latestVersion` is newer (not installed yet), just tell the owner a new release exists. grok's own auto-update installs it; re-derive once it's installed.
   - Stay silent when nothing changed.
   - **Never** run `grok update` yourself, and never touch live sessions, TUIs, or running turns from the routine.
   - In chief + workers mode only the chief owns this routine; workers just do the per-use drift check.
3. **Upstream.** When your adapted copy has moved past the published template (your **Verified against** is newer than the template's, or you rewrote commands), you may tell the owner that the upstream repo `Qervas/remote-grok-build` may have a newer version (see its `CHANGELOG.md`). Let them decide; never overwrite their customizations with upstream text unasked.

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
  - `grok-mission-control.ps1`: LIVE / STALE / RUNNING / idle inventory, plus version drift
  - `grok-turn.ps1`: launch a headless turn in the background, NDJSON to a log
  - `grok-interrupt.ps1`: stop a headless turn (process tree) by PID or session id
  - `grok-after-turn.ps1`: reply pack (state, reply text, new images, git, summary)

## CLI cheat sheet (grok 1.0.63–1.0.81)
| Need | Use |
|------|-----|
| Version / update state | `grok --version` · `grok update --check --json` (don't run `grok update` unasked) |
| List / search sessions | `grok sessions list -n 20` · `grok sessions search "<q>" -n 20`. **Scoped to the current directory**, so `Set-Location` to the project folder first (the subcommand has no `--cwd`). Worktree sessions started from the same subfolder are included; sibling submodules are hidden. For an all-folders view use `grok sessions list --all -n 20` (1.0.81+), or scan `~/.grok/sessions` (mission control; works on every version). Never run `grok sessions delete` unasked. |
| Resume a turn | `grok --cwd '<cwd>' -r '<session_id>' -p '<text>'`. `-r` also takes a title (current dir). Since 1.0.59–1.0.62: word separators and word order are ignored (`fix-login-bug` finds "Fix login bug"; every typed word must appear), an exact single ID/title match opens directly (no picker), and a miss lists suggestions / reports immediately instead of trying remote restore. Among duplicate titles a sole renamed match wins; otherwise the resume fails as ambiguous. Since 1.0.65–1.0.66, titles in Chinese/Japanese and other scripts without spaces match by words that start inside a title word (`登录 问题` finds "修复登录问题"). Since 1.0.68, on the daemon route a session ID also finds a session held at the same place in the repo's main checkout or one of its `grok -w` worktrees and opens it there. Scripts should still pass the UUID with the session's own `--cwd`. `-c` = most recent in cwd. Since 1.0.79 (`features.unified_session_import`, default on) `-r <id>` can also open a session saved by Grok's unified build as a **new native copy** with a different session id (read the new id from `end`/`json` and track that one); `-c` only sees native sessions. |
| Extra folders (new session only) | `--add-dir <DIR>` (1.0.67+, repeatable; relative paths start from `--cwd`). Refused if the folder isn't trusted or the agent is limited to its working directory. **Cannot be combined with `-r`/`-c`** (clap error, exit 2): a resumed session keeps the folders it was created with, so pass it only on the first turn. Since 1.0.69 an added folder also applies its own `deny`/`ask` permission rules (its `allow` rules and `defaultMode` don't apply), so it can only make the session stricter. |
| Fork instead of append | add `--fork-session` (optionally `-s <new-uuid>` to name the fork). With `-w -r` the fork runs in the new worktree's path (1.0.54+). |
| New session with a known id | `-s <uuid>` (must be a fresh valid UUID, **lowercase and hyphenated**: the daemon route refuses uppercase since 1.0.81, so use `[guid]::NewGuid().ToString()`; **no longer upserts or resumes**) |
| Long / quoted prompt | `--prompt-file <path>` (avoids PowerShell quoting; a leading byte-order mark is stripped since 1.0.52); `--prompt-json '<blocks>'` for content blocks (images; pasted images over 50 MB are rejected) · `--verbatim` sends the prompt exactly as given |
| Live progress | `--output-format streaming-json` (type-tagged NDJSON; verified on 1.0.63) |
| Messages-API stream | `--output-format streaming-messages-json` [+ `--include-partial-messages` for deltas] |
| Final result + session id + spend | `--output-format json` → `text`, `stopReason`, `sessionId`, `requestId`, `cwd` (the folder actually used, including a `-w` worktree), `usage`, `num_turns`, `total_cost_usd` (+ `total_cost_usd_ticks`), `modelUsage`, and `thought` (the model's reasoning; never relay it as the reply) · `--json-schema '<schema>'` for structured output (implies `json`) |
| Approvals | `--always-approve` (alias `--yolo`, = `--permission-mode bypassPermissions`). Others: `default`, `acceptEdits`, `auto`, `dontAsk`, `plan`. Since 1.0.80 the interactive TUI defaults to `auto` (Auto-review); headless `-p` keeps its own default, so pass `--permission-mode` when the mode matters. On the daemon route `default` (ask) also runs local read-only shell commands without a prompt (`features.ask_local_reads`, default on). Since 1.0.65–1.0.66, headless `--permission-mode plan` holds plan mode for the whole `-p` run (also on `-r`/fork): only the plan file can be edited, and other edits are refused with exit code 0, so use it for plan-only turns, not for implementation. `--allow`/`--deny` rules still apply (`--allowed-tools`/`--allowedTools` alias `--allow`, `--disallowedTools` aliases `--deny`). |
| Model / effort | `-m <model>` (`grok models` lists them) · `--effort none…max` (model-dependent, e.g. `xhigh`) |
| Guardrails | `--max-turns N`, `--tools`, `--disallowed-tools` (takes model-facing names like `run_terminal_command`, `spawn_subagent`), `--rules`, `--sandbox <profile>`, `--no-subagents`, `--disable-web-search` |
| Background goals / tasks | Headless `-p` waits for background goals (1.0.51+) **and**, since 1.0.62, for the follow-up turn a finished background task starts before exiting. `--background-wait-timeout` caps that wait and now exits with an **error** (not success) when it stops pending work (still not shown in `--help`; accepted on 1.0.63, 1.0.64, 1.0.66, 1.0.67 and 1.0.69, verified). Bridge scripts that wait on the process PID already cover this longer exit. 1.0.68+ adds hidden `--background-shell-timeout <secs>`: it stops only lingering background **shells** that long after the latest turn (subagents are still waited on, and the run doesn't fail), it **cannot be combined with `--background-wait-timeout`** (clap error), and it only works when the session runs on the daemon route (otherwise grok exits with `--background-shell-timeout is only supported when the session runs on the daemon`). The bridge doesn't pass it. Since 1.0.79 a **workflow run is not waited for** on either route: the headless run exits once the first turn and other background work end, a still-running workflow's result never reaches the output, and a workflow run's outcome never changes the exit code (exit `1` still means a failed turn or background work stopped when the wait ran out). |
| Quiet updates during a turn | `--no-auto-update` (or env `GROK_DISABLE_AUTOUPDATER=1`). Not listed in `--help`; still accepted on 1.0.63 (verified 2026-10-18) 1.0.64 (2026-10-20), 1.0.66 (2026-10-21), 1.0.67 (2026-10-22), 1.0.69 (2026-10-23, binary check), 1.0.70 (2026-10-24, binary check), 1.0.71 (2026-10-27, binary check), 1.0.72 (2026-10-28, binary check), 1.0.73 (2026-10-29, binary check), 1.0.74 (2026-11-03, binary check), 1.0.77 (2026-11-05, binary check), 1.0.78 (2026-11-06, binary check) and 1.0.79 (2026-11-08, binary check), 1.0.80 (2026-11-10, binary check), 1.0.81 (2026-11-11, binary check). |
| Transcript / spend | `grok export <id> [out.md]` (`out.md` must not exist yet; export refuses to overwrite since 1.0.52) · `grok usage <id> [turn]` · `grok du` = disk use of `~/.grok` |
| Worktrees | `-w [name]` (+ `--worktree-ref <ref>`); with a remote session `--restore-code` |
| Agent dashboard (TUI) | `grok dashboard` (local screen only) |
| Sharing | `/share` and session sharing were removed from the CLI in 1.0.51; send transcripts with `grok export` instead |

## Storage map (`~/.grok`)
| Path | Role |
|------|------|
| `active_sessions.json` | Open TUI sessions: `session_id` / `pid` / `cwd` / `opened_at` (may be stale; check the pid). Since 1.0.54 a corrupt file is backed up and salvaged by grok, so tolerate unreadable rows instead of failing |
| `sessions/<url-encoded-cwd>/<session-id>/` | All sessions (`[uri]::EscapeDataString(cwd)`) |
| `…/summary.json` | Index entry: `info.id`, `info.cwd`, `generated_title`, `session_summary`, `last_turn_summary`, `last_recap`, `current_model_id`, `reasoning_effort`, `agent_name`, `head_branch`, `updated_at`/`last_active_at`, `num_chat_messages` |
| `…/chat_history.jsonl` · `prompt_context.json` · `rewind_points.jsonl` | Chat log, prompt context, rewind points (`*.lock` files sit beside them; never delete them) |
| `…/updates.jsonl` | Authoritative ACP update log (`_x.ai/session/update` lines: `agent_message_chunk`, `tool_call`, `turn_completed`, `session_recap`, …) |
| `…/events.jsonl` · `usage.json` · `signals.json` | Event log, token/cost usage, turn signals |
| `…/images/` · `…/assets/` | Session media. Both also hold what the **user** sent: TUI pastes land in `images/`, `--prompt-json` image blocks land in `assets/`. `grok-after-turn.ps1 -Meta` skips this turn's inbound files so they aren't echoed back. |
| `…/terminal/` · `compaction/` · `subagents/` | Tool command logs, compaction segments, child sessions |
| `version.json` | Cached installed/latest version from the update check |
| `trusted_folders.toml` | Trusted projects |
| `config.toml` / `auth.json` / `mcp_credentials.json` | **Never read into chat or paste secrets** |

**Auto-update gotcha:** when grok self-updates while a TUI is open, the running binary is renamed to `grok.exe.old`. That TUI keeps the old version; `Get-Process` names it `grok.exe.old` while CIM still says `grok.exe`. Match processes by PID from `active_sessions.json`, not by process name, and label such a LIVE row "old binary" (it picks up the new version on its next launch). Since 1.0.68 a running session no longer breaks when an update deletes its binary, so an auto-update mid-turn is safer, but keep `--no-auto-update` on bridge turns anyway. Since 1.0.70 the env var `GROK_UPDATE_CHANNEL` pins the update channel (set it in the PC's user environment so the background updater sees it too), and `grok inspect` shows the resolved channel and version floor/ceiling. Since 1.0.74, under any sandbox profile except `off` (`--sandbox`, `GROK_SANDBOX` or config), grok never starts an update on its own: it only notifies (`grok agent` prints the notice on stderr) and a typed `grok update` installs, so a PC that always runs sandboxed stays on its version until someone updates it. `grok update --check --json` reports `installer` (`internal` on a standard install). Since 1.0.79 the updater recognizes a grok started by npm's launcher (`GROK_MANAGED_BY_NPM`) and repairs a config that wrongly recorded `npm` for a build under `~/.grok/downloads`.

## 1) Mission control (`status`)
Run `grok-mission-control.ps1` (or scan `~/.grok` the same way).
Pass `-VerifiedVersion <Verified against>` (add `-CheckLatest` to also query the latest release). It prints `DRIFT=…` before the rows; act on it per **Stay current**.
**Order:** LIVE → STALE → RUNNING headless → idle/history (newest first), by folder.
Widgets (max 6): LIVE, then idle projects, then sessions. Show title, last turn summary, model/effort, branch.
If a worker already owns that `cwd`, offer dispatch to that worker.

## Idle / not-live sessions
Do **not** require a LIVE hold before a remote chat turn. Cold-open idle sessions with headless `grok -r <session_id> -p …` and `--cwd` set to the session's folder (`summary.json` → `info.cwd`). Holding LIVE is optional, only for LIVE-tier visibility or watching a TUI. If the folder no longer exists, grok now fails fast; tell the user rather than recreating it.

Avoid driving the **same** session headless while its TUI is open and busy (two writers); offer `--fork-session` or wait.

## 2) Send a turn with live progress (streaming)
Preferred: background launch + poll, so the bot can post milestones and still interrupt. The turn keeps running after the computer-link command returns (verified).
```powershell
& "$HOME\.grok-bridge\grok-turn.ps1" -Cwd '<cwd>' -SessionId '<session_id>' -Prompt '<intent>'
# → PID=<pid> LOG=<path.ndjson> META=<path.json>; omit -SessionId for a new session (its id arrives on the end line)
# then poll every few seconds: Get-Process -Id <pid>  +  read new LOG lines
```
Poll rather than using `-Wait`: a long blocking command on the remote link can be cut off. Each headless turn also starts the user's MCP servers, so the first events can take a few seconds.
Direct form (blocks until done):
```powershell
grok --cwd '<cwd>' -r '<session_id>' --prompt-file '<prompt.txt>' --always-approve --no-auto-update --output-format streaming-json
```
Read `streaming-json` by switching on `type` (observed on 1.0.50, re-checked on 1.0.55 and 1.0.63):
- `text` / `thought`: response / reasoning chunks in `data` (token-sized; concatenate)
- `tool_call`: `toolCallId`, `toolName`, `title`, `kind`, `status:"pending"`, `rawInput`. Seen names: `write` (kind `write`, `rawInput.file_path`/`content`), `run_terminal_command` (kind `execute`, `rawInput.command`), `read_file`, `search_replace`, `grep`, `list_dir`
- `tool_call_update`: same `toolCallId`; `status` goes `null` → `in_progress` → `completed`/`failed`. `content` holds diffs (`type:"diff"`, `path`, `oldText`, `newText`) or text. Shell updates **resend the full accumulated output** each time (`content[].content.text` plus a `rawOutput.output` byte array), so keep only the latest per `toolCallId` and show its tail.
- `available_commands`: tool/slash lists, repeated dozens of times per turn. Ignore.
- `usage`: per model response (`usage`, `signature`; `messageId`/`stopReason` may be absent). On the daemon route (1.0.75+) one per turn, subagent turns included, with only that turn's total. Since 1.0.79 a daemon-route response that called tools also ends with an extra `usage` line **before** its tool calls with all counts 0; skip those. Don't add these up: `end`'s spend already sums every turn the run made (wake/goal turns too, since 1.0.75)
- `plan` (`entries`), `max_turns_reached`, `auto_compact_*`
- `end`: last line, with `stopReason` (`end_turn`, `max_tokens`, `max_turn_requests`, `refusal`, `cancelled`), `sessionId`, `requestId`, `cwd`, `usage`, `num_turns`, `total_cost_usd` (+ `total_cost_usd_ticks`), `modelUsage` (per model, with `costUSD`)
- `error`: `message`, non-zero exit
Treat unknown types as non-fatal. (Fallback only: if a future build emits raw ACP lines with `sessionUpdate` instead of `type`, map `agent_message_chunk`→text, `agent_thought_chunk`→thought, the rest by name, and re-derive per **Stay current**.)

Post **sparse** milestones (tool started/finished, plan changes), not every chunk. Exit codes: 0 ok, 1 error, 130 SIGINT, 143 SIGTERM. A force-stopped turn writes **no `end` line**: process gone + no `end` = stopped. Since 1.0.74 a *graceful* SIGINT/SIGTERM after the prompt was sent (not the bridge's `taskkill /F`) instead stops background work for up to ~10 s and ends with `end` `stopReason:"cancelled"` (empty `requestId`, `usage_is_incomplete: true`, usage is a lower bound), or `error` after a failed prompt; a second signal forces the exit without the closing line. Treat `end`+`cancelled` as stopped too.

## 3) Stop / interrupt
`grok-interrupt.ps1 -ProcessId <PID from grok-turn>` (or `-SessionId <id>`) kills the matching **headless** grok process **and its child tree**: tool shells and their children (verified: `pwsh` → `PING.EXE` gone) plus the MCP servers that turn started. It never touches TUIs unless `-IncludeTui` is passed explicitly, and refuses with no target. Session state is kept up to the last completed tool call; file edits are not rolled back. Since 1.0.52 grok also stops its own shell commands when it quits or gets a signal, so a stop leaves no orphaned tool shells (re-verified on 1.0.55 and 1.0.63: grok and its tool shell both gone, no `end` line). Resume later with `-r <id> -p "continue"`. In multi-bot mode the chief forwards stop to the owning worker.

(Grok's ACP interface supports targeted per-response cancel for SDK clients; the CLI bridge uses process stop.)

## 4) After-turn pack
`grok-after-turn.ps1 -Meta <META from grok-turn>` (or `-Cwd <cwd> -SessionId <id> -SinceIso <turn start> -Log <LOG>`) → `STATE` (`end_turn`, `stopped(no end line)`, `running`, …), session id (also for new sessions), reply text, **new images** (inbound files skipped) to CopyToBox into chat, git branch/diffstat (repos only), `last_turn_summary`, optional `grok usage <id>` spend.

## Bidirectional media
- **Out:** new files in `…/images/` and `…/assets/` (plus project outputs) → CopyToBox → show in chat.
- **In:** chat attachment → CopyFromBox to `<cwd>\.grok-bridge-in\` (or `~\.grok-bridge\in\`) → pass as a content block:
  `--prompt-json '[{"type":"text","text":"<ask>"},{"type":"image","mimeType":"image/png","data":"<base64>"}]'`
  `grok-turn.ps1 -Images <paths>` builds this (verified: a 160×160 PNG was read correctly, with no tool calls). Windows command lines cap near 32k chars, so images past ~22 KB fall back to a text prompt naming the staged path for grok to open (fallback not live-tested). Downscale/compress large images first to stay inline.

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
- Run `grok update` (even from the daily watch), `grok sessions delete`, `grok logout`, `grok worktree rm`, `grok leader kill`, `grok worker start` or the hidden `grok cursor-worker` (both register the PC as a Cursor private worker, 1.0.64+) unasked
- Create more than one self-update routine per bot
- Use public tunnels or relays; hide idle sessions; leave images on disk only; paste grok secrets; use Cursor CloudAgent for this
