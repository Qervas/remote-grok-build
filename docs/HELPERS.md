# Optional bridge helpers (`~/.grok-bridge`)

Live-tested with `grok 1.0.50` and re-tested unchanged on `grok 1.0.55` (2026-10-14) on PowerShell 7 (parse-checked on Windows PowerShell 5.1): new turn, resume, image in, interrupt, after-turn, mission control.

| Script | Role |
|--------|------|
| `grok-mission-control.ps1` | LIVE / STALE / RUNNING / idle inventory → `~/.grok-bridge/grok-mission-control.json`. Prints `DRIFT=none|newer|older` against `-VerifiedVersion` (the skill's "Verified against"); `-CheckLatest` adds the latest release via `grok update --check --json` (read-only). Flags LIVE TUIs still running a pre-update `grok.exe.old` binary. Read-only. |
| `grok-turn.ps1` | Launch one headless turn in the background (`--resume`, `--fork-session`, `-m`, `--effort`, `--max-turns`, `--permission-mode`). Writes the prompt to a file (`--prompt-file`) to dodge quoting, or builds `--prompt-json` with image blocks. Streams `streaming-json` NDJSON to `~/.grok-bridge/turns/<id>-<utc>.ndjson`; META records pid, start time and inbound image hashes. The turn survives the launching command. `-DryRun` prints the command line; `-Wait` blocks and prints the `end` line (prefer polling on a remote link). |
| `grok-interrupt.ps1` | Stop a headless turn by `-ProcessId` (from the grok-turn META) or `-SessionId`, killing its child tree (`taskkill /T /F`). TUIs only with `-IncludeTui`; no target means refuse (use `-AllHeadless` to opt in). |
| `grok-after-turn.ps1` | Reply pack from `-Meta <META>` (or `-Cwd/-SessionId/-SinceIso/-Log`): `STATE` (stop reason, `stopped(no end line)` after an interrupt, or `running`), session id (also for new sessions), reply text, new images/assets minus this turn's inbound files, git (repos only), summary fields. Finds worktree/relocated sessions by id. |

Copy from `helpers/` into `~/.grok-bridge/` on the linked PC. Paths stay portable; never hardcode another user's home.

## Typical flow
```powershell
& "$HOME\.grok-bridge\grok-mission-control.ps1" -VerifiedVersion 1.0.55   # DRIFT=newer → re-derive per the skill's "Stay current"
& "$HOME\.grok-bridge\grok-turn.ps1" -Cwd 'C:\path\proj' -SessionId '<uuid>' -Prompt 'next step'
#   → PID=… LOG=…ndjson META=…json ; poll Get-Process -Id PID + new LOG lines, post milestones
& "$HOME\.grok-bridge\grok-interrupt.ps1" -ProcessId <PID>          # if the user says stop
& "$HOME\.grok-bridge\grok-after-turn.ps1" -Meta '<META>'
```
