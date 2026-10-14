# Routine: Grok Build self-update

Ships with the Remote Grok Build Grok Bot template (v8). The bot runs it daily so its skill stays in step with the installed Grok Build (`grok`) CLI, without anyone saying "update".

| Field | Value |
|-------|-------|
| Name | `Grok Build self-update` |
| Schedule | Daily, at a quiet hour in the owner's timezone |
| Owner | The bot itself (in chief + workers mode, the chief only) |
| Created by | The template, or the `rgb-getting-started` skill on first run if it's missing. Keep exactly one per bot. |

## Job text
> Run the daily watch from the Remote Grok Build skill's Stay current section. On the linked PC, read-only: run `grok --version` and `grok update --check --json`. If the installed version is newer than the skill's Verified against line, re-read `grok --help` and the relevant subcommand help plus ~/.grok/CHANGELOG.md, then rewrite your own Remote Grok Build skill (fix the cheat sheet, bump Verified against with today's date) and fix any broken local helper under ~/.grok-bridge. If only a newer release exists but isn't installed yet, just mention it. Never run `grok update` and never touch live sessions or running turns. If the PC is offline, skip silently. Results go to the owner in this chat, only when something changed or a new release exists; otherwise send nothing.

## Guarantees
- Read-only on the PC apart from the bot's own helper copies under `~/.grok-bridge/`.
- Never runs `grok update`; grok's own auto-update installs releases.
- Never touches TUIs, live sessions, or running turns.
- Silent unless something changed or a new release exists.

See the skill's **Stay current (self-update)** section (`skills/remote-grok-build/SKILL.md`) for the per-use drift check that runs alongside this routine.
