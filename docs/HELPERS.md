# Optional bridge helpers (`~/.grok-bridge`)

Tested with `grok 1.0.50` on Windows PowerShell 5.1 and PowerShell 7.

| Script | Role |
|--------|------|
| `grok-mission-control.ps1` | LIVE / STALE / RUNNING / idle inventory → `~/.grok-bridge/grok-mission-control.json`. Flags LIVE TUIs still running a pre-update `grok.exe.old` binary. Read-only. |
| `grok-turn.ps1` | Launch one headless turn in the background (`--resume`, `--fork-session`, `-m`, `--effort`, `--max-turns`, `--permission-mode`). Writes the prompt to a file (`--prompt-file`) to dodge quoting, or builds `--prompt-json` with image blocks. Streams `streaming-json` NDJSON to `~/.grok-bridge/turns/<id>-<utc>.ndjson`. `-DryRun` prints the command line; `-Wait` blocks and prints the `end` line. |
| `grok-interrupt.ps1` | Stop a headless turn by `-ProcessId` (from the grok-turn META) or `-SessionId`, killing its child tree (`taskkill /T /F`). TUIs only with `-IncludeTui`; no target means refuse (use `-AllHeadless` to opt in). |
| `grok-after-turn.ps1` | Reply pack: new images/assets since the turn started, git branch/head/status/diffstat (repos only), summary fields, and the final `end` line from a turn log (`-Log`). Finds worktree/relocated sessions by id. |

Copy from `helpers/` into `~/.grok-bridge/` on the linked PC. Paths stay portable; never hardcode another user's home.

## Typical flow
```powershell
& "$HOME\.grok-bridge\grok-mission-control.ps1"
& "$HOME\.grok-bridge\grok-turn.ps1" -Cwd 'C:\path\proj' -SessionId '<uuid>' -Prompt 'next step'
#   → PID=… LOG=…ndjson META=…json ; tail LOG, post milestones
& "$HOME\.grok-bridge\grok-interrupt.ps1" -ProcessId <PID>          # if the user says stop
& "$HOME\.grok-bridge\grok-after-turn.ps1" -Cwd 'C:\path\proj' -SessionId '<uuid>' -SinceIso '<started_at>' -Log '<LOG>'
```
