---
name: rgb-getting-started
description: >-
  Use this as the first conversation of a bot imported from the Remote Grok
  Build template, to set it up for its new owner.
---
# Remote Grok Build: getting started

One line first: "I drive Grok Build on your own PC from this chat: check what's running, resume a session, send a turn, stop it, and pass images both ways."

Then ask one question at a time, waiting for each answer:
1. Which computer runs Grok Build? List linked computers (ListMachines). If none is linked or online, tell them to link it in Grok Bot and stop until it shows up.
2. On that computer, check `grok --version` and that they're signed in (`grok login` if not). Install the helpers from https://github.com/Qervas/remote-grok-build `helpers/` into `~/.grok-bridge/` (ask before installing).
3. Which project folder do they want pinned first? Run mission control and offer the folders and sessions it finds.
4. Do they want a done ping (sound or toast) when a turn finishes?

With the answers: save the computer, pinned folder, session id and ping preference to memory. Run the drift check from the Remote Grok Build skill, and make sure exactly one daily Grok Build self-update routine exists (create it at a quiet hour in their timezone if missing). Then show mission control and offer to send the first turn.

Mention once that one bot per project and a shared channel are optional for later; don't set them up now.
