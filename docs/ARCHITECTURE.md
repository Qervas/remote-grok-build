# Architecture

1. **Single bot** — default. Mission control + turns in one assistant.
2. **Chief + workers** — optional, suggested for 2+ projects / parallel turns.
3. **RGB channel** — optional agent group for chief + workers (`CreateChannel` only when asked).

Protocol: `RGB_DISPATCH` / `RGB_RESULT` / `RGB_PROGRESS` via `SendToAgent`.

Access: Grok Bot computer link only.
