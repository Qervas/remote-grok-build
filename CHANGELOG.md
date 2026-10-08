# Changelog

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
