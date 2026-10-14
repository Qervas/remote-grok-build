# Grok Bot template contents (v8)

**Status:** v8 is staged for publishing and **not public yet**. The public link in the README still serves v6.

| Part | Source in this repo |
|------|---------------------|
| Skill: Remote Grok Build | `skills/remote-grok-build/SKILL.md` |
| Skill: RGB getting started (first run) | `skills/rgb-getting-started/SKILL.md` |
| Routine: Grok Build self-update (daily) | `routines/grok-build-self-update.md` |
| PC helpers (installed on first run, with consent) | `helpers/` → `~/.grok-bridge/` |

First conversation: `rgb-getting-started` picks the linked PC, checks `grok --version` and sign-in, installs helpers, pins a project, runs the drift check, and makes sure exactly one self-update routine exists.

Access stays on the Grok Bot computer link only (no tunnels). Chief → worker bots and the RGB channel remain optional.
