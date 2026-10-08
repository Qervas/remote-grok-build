# Architecture

1. **Single bot**: default. Mission control + turns in one assistant.
2. **Chief + workers**: optional, suggested for 2+ projects / parallel turns.
3. **RGB channel**: optional agent group for chief + workers (`CreateChannel` only when asked).

Protocol: `RGB_DISPATCH` / `RGB_RESULT` / `RGB_PROGRESS` via `SendToAgent` (v7 adds `fork`, `model`, `effort`, `max_turns`, `images` on dispatch and `stop_reason`, `usage` on result).

Turn engine: headless `grok --cwd <cwd> -r <session_id>` with `--output-format streaming-json`, launched in the background by `grok-turn.ps1` and tailed by the bot. Interrupt = stop that PID tree.

Access: Grok Bot computer link only (no tunnels, no `grok agent headless`/`serve` relays).
