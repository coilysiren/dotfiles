---
name: kai-execution-mode-mac
description: Posture rules for Kai's Mac desktop app client (local server or remote dispatch to KAI-SERVER). Medium automation with frequent escalation to AskUserQuestion, high data-safety environment (low leak risk, home network, trusted screen). Obsidian vault inbox is reachable only here. Triggers - mac, macos, darwin, desktop app, home laptop, obsidian inbox, vault inbox, local server, remote dispatch from mac.
---

# Execution mode: Mac desktop app

Loaded by [`kai-execution-mode`](../kai-execution-mode/SKILL.md) when Platform is `darwin`, or when the user is dispatching to KAI-SERVER from the Mac desktop app.

## Posture

* **Automation** - Medium. Proceed on read-only and clearly-reversible work. Escalate via AskUserQuestion for destructive ops, ambiguous scope, or anything that touches public surfaces (social, public repos).
* **Data safety** - High. Home network, trusted screen, no shoulder surfing. Private context (vault, drafts, secrets in commands as `FILL_ME_IN`) is fine to surface.
* **Permission walls** - Prompt is acceptable. Kai is at the keyboard and can approve.

## Reachable data

* Obsidian vault at `/Users/kai/projects/coilysiren/coilyco-vault/` - **only reachable here**. Daily routines that write inbox files (`daily-operational`, `daily-social`, etc.) only run from this mode. Reach into the vault freely when private context helps.
* `~/data/` bulk private dirs - only here.
* All `coilysiren/*` repos.

## Input: Wispr Flow dictation

Assume Kai's prompts on Mac arrive via Wispr Flow voice dictation, not typed. Quirks to expect and absorb without nitpicking:

* **Homophones and near-homophones** - "their/there/they're", "to/two/too", "right/write", "claw/Claude/cloud", "coily/coiley/coyly", "eco/echo", "SSM/SSH". Pick the meaning that fits the surrounding technical context. Do not ask which one she meant unless both readings produce real and divergent actions.
* **Misheard proper nouns** - command, repo, and tool names get mangled (e.g. "co-wily", "coyote AI", "open claw" vs "openclaw", "obsidian" rendered as "obsession"). Map back to the canonical names from this file and skills before acting.
* **No punctuation, or wrong punctuation** - run-on sentences, missing commas, stray "period" / "comma" / "new line" tokens that leaked through. Parse for intent, do not parse literally. A trailing "okay" or "right" is filler, not a question.
* **Capitalization is unreliable** - treat case as noise for identifiers, paths, flags.
* **Self-corrections mid-stream** - "update the Mac directions, I mean the Mac host directions" - take the latest restatement as the live one.
* **Filler and false starts** - "um", "uh", "so basically", "you know", repeated words. Strip silently.
* **Dictated code or paths is rare** - if a path or command sounds dictated (spaces where slashes belong, "dot py" for `.py`), reconstruct the literal form before running it. If the reconstruction is ambiguous and the action is destructive, escalate via AskUserQuestion. Reversible reconstructions proceed.

Do not surface the dictation noise back to her. No "did you mean X". Just act on the cleaned reading.

## Mechanics pointer

This skill owns posture. For Mac shell mechanics (zsh, `/opt/homebrew/bin`, paths), there's no dedicated `kai-mac-env` skill yet - the AGENTS.md Environment section covers it.

## Differences from windows

* Vault is here, not on Windows.
* zsh, not Git Bash.
* Automation tilts higher than Windows because Claude works well on Mac.

## See also

* [`kai-execution-mode`](../kai-execution-mode/SKILL.md) - router.
* [`kai-execution-mode-windows`](../kai-execution-mode-windows/SKILL.md) - sibling mode.
* [`vault-rules`](../vault-rules/SKILL.md) - vault layout, only reachable from this mode.
