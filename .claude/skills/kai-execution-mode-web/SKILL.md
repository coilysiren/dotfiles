---
name: kai-execution-mode-web
description: Posture rules for Kai's Chrome web UI client (claude.ai), usually running in public or at Kapwing. High automation but low data safety - assume the screen is observable. On a permission wall, STOP and report rather than prompt. Triggers - chrome, web, claude.ai, browser, kapwing laptop, work laptop, public, cafe, observable screen, low data safety.
---

# Execution mode: Chrome web UI

Loaded by [`kai-execution-mode`](../kai-execution-mode/SKILL.md) when the user confirms the Chrome web UI client. Server is always KAI-SERVER (remote dispatch).

## Posture

* **Automation** - High. Web UI is fine for long autonomous runs, and Kai is often heads-down on other work.
* **Data safety** - Low. Assume the screen is observable: Kapwing office, cafes, anywhere with shoulder-surf risk. Do not surface secrets, full email addresses, real-name identifiers, or vault content. Even `FILL_ME_IN` commands should not echo decrypted values back. No private identity tags ever.
* **Permission walls** - **Stop on permission walls. Do not prompt.** Emit a one-line summary of where you stopped and what would unblock it. Do not call AskUserQuestion. Do not retry. The reason is that Kai is on a public surface and may not be paying attention to the chat - a prompt could sit unanswered, or worse, a passerby could see the prompt context.

## Reachable data

* Whatever KAI-SERVER can reach via coily.
* **No vault** - private vault content must not appear in this mode regardless of reachability.
* **No `~/data/`** bulk dirs.
* Kapwing-related work is fine - this is the mode where `kai-kapwing-pr-review` is most useful.

## Output shape

* Public-safe by default. Apply `writing-coilyco-ai` leak-check discipline as if every response could be screenshotted.
* No network detail, no street addresses, only `coilysiren@gmail.com` for any email reference.

## The stop-don't-prompt rule

If you would normally call AskUserQuestion, instead:

1. Write one line stating the decision you faced and the option you'd recommend.
2. Stop. Do not retry. Do not fall through to a "safer" alternative that's a different action.
3. Let Kai resume the session later with explicit guidance.

This is the load-bearing difference between this mode and android. Both are high-automation, but android can prompt cheaply (Kai is holding the phone). Web cannot.

## See also

* [`kai-execution-mode`](../kai-execution-mode/SKILL.md) - router.
* [`kai-execution-mode-android`](../kai-execution-mode-android/SKILL.md) - other high-automation mode (opposite data-safety posture).
* `writing-coilyco-ai` - public-safety rules that apply even harder here (lives in coilyco-ai).
* `kai-kapwing-pr-review` - common task in this mode (lives in coilyco-ai).
