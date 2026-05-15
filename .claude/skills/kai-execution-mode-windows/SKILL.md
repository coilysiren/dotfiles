---
name: kai-execution-mode-windows
description: Posture rules for Kai's Windows desktop app client (local Git Bash server or remote dispatch to KAI-SERVER). Low automation in local-server mode because Claude on Windows is rough, maximum data safety (lives alone, good auth hygiene even on desktop). Triggers - windows, win32, git bash, desktop pc, home desktop, local windows server, remote dispatch from windows.
---

# Execution mode: Windows desktop app

Loaded by [`kai-execution-mode`](../kai-execution-mode/SKILL.md) when Platform is `win32`, or when the user is dispatching to KAI-SERVER from the Windows desktop app.

## Posture

* **Automation** - Low in local-server mode (Claude on Windows is rough: MSYS path mangling, harness quirks, denylist bypass bugs). Medium when dispatching to KAI-SERVER from this client. When in doubt on the local-server side, ask.
* **Data safety** - Maximum. Kai lives alone, has good auth hygiene on the desktop, no shoulder surfing. This is the safest screen.
* **Permission walls** - Prompt is fine. Local-server quirks mean prompts happen more often anyway.

## Reachable data

* All `coilysiren/*` repos (under `X:\projects-x\coilysiren\`).
* No Obsidian vault here.
* No `~/data/` bulk dirs here.

## Mechanics pointer

For Windows shell mechanics (Git Bash always, MSYS paths, MSIX-sandboxed Claude Desktop, install-path priority, denylist bypass bug), see `kai-windows-env` (lives in coilyco-ai). Posture lives here, mechanics live there.

## Differences from mac

* Local-server work is less reliable. Prefer remote dispatch to KAI-SERVER when the task is non-trivial.
* Vault is not here. If a task wants private vault context, the user has to copy-paste or switch to the Mac.
* Auth hygiene is strong enough that secrets in command output (still as `FILL_ME_IN` placeholders) are acceptable.

## See also

* [`kai-execution-mode`](../kai-execution-mode/SKILL.md) - router.
* [`kai-execution-mode-mac`](../kai-execution-mode-mac/SKILL.md) - sibling mode.
* `kai-windows-env` - shell mechanics (lives in coilyco-ai).
