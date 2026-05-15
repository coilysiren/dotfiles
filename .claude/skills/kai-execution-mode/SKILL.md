---
name: kai-execution-mode
description: Router for Kai's Claude execution modes. Detects client (Mac/Windows desktop, Android, Chrome web) and server (local vs remote KAI-SERVER), loads matching kai-execution-mode-* child to set automation level and data-safety posture. Use at session start or when deciding prompt-vs-proceed-vs-stop on a permission wall. Triggers - execution mode, which client, mobile, android, web ui, kapwing, desktop app, remote dispatch, permission wall, stop or prompt, escalate.
---

# Execution mode router

Kai runs Claude across four distinct client surfaces, each with different automation × data-safety posture. The router picks one mode and the matching child skill owns the rules.

## Modes

* **mac** - Mac desktop app client. Local or remote server. Medium automation, high data safety. Obsidian vault inbox reachable.
* **windows** - Windows desktop app client (Git Bash). Local or remote server. Low automation in local-server mode (Claude on Windows is rough), max data safety.
* **android** - Android app client, always remote server. High automation, medium data safety. Poor mobile usability.
* **web** - Chrome web UI client. Public / Kapwing surfaces. High automation, low data safety. **Stop on permission walls rather than prompt.**

## Detection

Auto-detectable from the env block:

* `Platform: darwin` → mac client (the Mac desktop app is the only Claude client on macOS Kai uses).
* `Platform: win32` → windows client.
* `Platform: linux` + hostname `KAI-SERVER` → remote server. Client side is **not** auto-detectable from here. The remote-server case fans out to mac / windows / android / web depending on what's holding the phone or laptop.

Not auto-detectable from any signal Claude sees:

* Android vs Chrome web vs desktop-app-driving-remote-server when Platform is linux.

So: if Platform is darwin or win32, the client is decided. If linux, ask once.

## Routing procedure

1. Check env block for `Platform`.
2. If `darwin` → load [`kai-execution-mode-mac`](../kai-execution-mode-mac/SKILL.md). Done.
3. If `win32` → load [`kai-execution-mode-windows`](../kai-execution-mode-windows/SKILL.md). Done.
4. If `linux` → server is KAI-SERVER (remote dispatch). Use AskUserQuestion once with the four client options. Then load the matching child skill.
5. Cache the answer for the rest of the session. Do not re-ask.

## When to invoke

* Session start, before the first command that has a posture-sensitive permission decision.
* Not needed for pure read-only research (web search, doc lookup, grep without acting on results).
* Required before: filing issues, committing, pushing, sending emails, posting to social, touching k3s, anything that hits a permission wall.

## When NOT to ask

* When the user message tells you the client directly ("I'm on my phone", "from Kapwing laptop"). Just pick the matching mode.
* When prior in-session context already established the mode. Trust it.

## See also

* [`kai-execution-mode-mac`](../kai-execution-mode-mac/SKILL.md)
* [`kai-execution-mode-windows`](../kai-execution-mode-windows/SKILL.md)
* [`kai-execution-mode-android`](../kai-execution-mode-android/SKILL.md)
* [`kai-execution-mode-web`](../kai-execution-mode-web/SKILL.md)
* `kai-linux-env` - mechanics for KAI-SERVER (PATH, coily, harness allowlist). Posture lives here, mechanics live there. (Lives in coilyco-ai.)
* `kai-windows-env` - mechanics for Windows host. (Lives in coilyco-ai.)
