---
name: kai-execution-mode-android
description: Posture rules for Kai's Android Claude app client, always dispatching to KAI-SERVER. High automation (mobile usability is poor, prompts are expensive), medium data safety (phone screen, can be in public). Prefer phone-friendly output - short, scannable, no wide tables, no long fenced blocks. Triggers - android, phone, mobile, dictation, train, voice dictation, on the go, remote dispatch android.
---

# Execution mode: Android app

Loaded by [`kai-execution-mode`](../kai-execution-mode/SKILL.md) when the user confirms the Android app client. Server is always KAI-SERVER (remote dispatch).

## Posture

* **Automation** - High. Mobile prompts are expensive and break dictation flow. Proceed on anything reversible. Reserve AskUserQuestion for genuinely destructive or ambiguous decisions, and when you do ask, offer 2-3 short options not 4.
* **Data safety** - Medium. Phone screen can be visible in public (train, cafe). Avoid surfacing secrets, full email addresses, real-name identifiers, or vault content unless the user has clearly asked for it. `FILL_ME_IN` placeholder discipline still applies.
* **Permission walls** - Avoid where possible. If you hit one, batch the asks - don't drip them one at a time.

## Noise floor

Mobile does not imply dictation-ready. Roughly 70% of Kai's would-be mobile sessions fail the ambient noise floor:

* BART and transit PA announcements regularly exceed comfortable dictation volume.
* Mask-wearing on BART (default, sickness avoidance) muffles dictation further.
* Cafes and other public spaces add their own floor.

Bias prep toward thumb-friendly artifacts (swipeable issue lists, GitHub notifications, PR review queues) over dictation-heavy interview flows (refactor-plan, grill-me, long RFC drafting). When suggesting mobile work, default to skim-and-tap shapes unless Kai signals a quiet environment.

## Output shape

* Short. A dictated paragraph in, a scannable paragraph out.
* No wide tables (mobile wraps badly anyway, and prose tables are banned per voice rules).
* Fenced code blocks fine but keep them under ~20 lines. The `$$ <cmd>` pattern (verbatim-echo) already enforces this for command output.
* One main result up top, details below. Phone users scroll less.

## Reachable data

* Whatever KAI-SERVER can reach: repos, k3s, AWS via coily, GitHub via coily ops gh, MCP servers configured on KAI-SERVER.
* **No vault** - the Obsidian vault is only on the Mac.
* **No `~/data/`** bulk dirs.

## Common patterns

* Voice-dictated paragraph → kick off a `coily` task or file a GitHub issue and report the URL.
* Long-running work should report through pollable channels (GitHub issue, vault inbox via the Mac later, Sentry). Don't make the phone hold state.

## See also

* [`kai-execution-mode`](../kai-execution-mode/SKILL.md) - router.
* [`kai-execution-mode-web`](../kai-execution-mode-web/SKILL.md) - other high-automation mode (opposite data-safety posture).
* `kai-linux-env` - KAI-SERVER mechanics (lives in coilyco-ai).
