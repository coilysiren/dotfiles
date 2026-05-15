---
name: tooling-hammerspoon
description: Hammerspoon is Mac-only Lua automation Kai uses to fix Wispr Flow's missing Return-after-paste. Use when editing init.lua, tuning the auto-Return loop, adding a blocked-app, debugging dictation that lands but never submits, or considering Hammerspoon for any other Mac glue. Triggers - hammerspoon, init.lua, wispr flow, flow, auto-return, auto-enter, dictation paste, flow-enter, BLOCKLIST, flagsTap, pasteboard, changeCount, fn key trigger.
---

# Hammerspoon

Mac-only Lua scripting bridge for OS-level automation. Kai uses it for one job today: fix Wispr Flow's missing Return-after-paste so dictated chat messages auto-submit.

## Config location

Canonical file: `~/projects/coilysiren/dotfiles/hammerspoon/init.lua`. Symlinked to `~/.hammerspoon/init.lua` by the dotfiles install steps.

Not cross-platform. Hammerspoon does not exist on Windows or Linux - the Wispr Flow auto-Return functionality has no equivalent on those hosts.

## The Wispr Flow auto-Return loop

Flow pastes dictated text into the focused field but doesn't press Return. For chat clients (Claude Code, Slack, iMessage, Bluesky web), this means every dictated message stalls until Kai manually hits Return. Annoying on the train.

The loop:

1. **Watch trigger release** - `flagsTap` listens for `flagsChanged` events. When the configured `TRIGGER` modifier (default `fn` / globe key) transitions from held to released, the dictation is presumed finished.
2. **Poll pasteboard** - `startPoll()` watches `hs.pasteboard.changeCount()` every `POLL_INTERVAL` (50ms) for up to `POLL_TIMEOUT` (3s). A tick means Flow finished pasting.
3. **Fire Return** - small grace delay (80ms) for the paste to fully land, then `keyStroke({}, "return")`.
4. **Verify and retry** - after `VERIFY_DELAY` (180ms), call `verifyAndRetry`. This presses Cmd+A then Cmd+C in the focused field. If `changeCount` ticks, something was selected = input still has text = Return didn't submit. Right-arrow to deselect, fire Return again. Up to `MAX_RETRIES` (2) retries.

The Cmd+A verify pass is the key trick. Some Electron / web fields ignore the first Return because focus isn't fully on the input yet. The retry handles that without false-firing on fields that already submitted.

## Blocked apps

Some apps want Return to insert a newline, not submit. `BLOCKLIST` checks the frontmost app's bundle ID before firing:

- `com.microsoft.VSCode`
- `com.apple.Terminal`
- `com.googlecode.iterm2`
- `com.github.wez.wezterm`
- `md.obsidian`
- `com.apple.TextEdit`

To add a new blocked app: find its bundle ID with `osascript -e 'id of app "AppName"'` or check `hs.application.frontmostApplication():bundleID()` in the Hammerspoon console, then add a row to `BLOCKLIST`.

## Tuning knobs

Top of `init.lua`:

- `POLL_INTERVAL` (0.05) - how often to check the pasteboard. Don't go below 0.02; pasteboard polling on macOS is cheap but not free.
- `POLL_TIMEOUT` (3.0) - max wait for Flow to paste. Bump if Flow's network round-trip is slow.
- `TRIGGER` ("fn") - which modifier release signals "dictation done". Change if Flow is configured to use a non-default hotkey.
- `VERIFY_DELAY` (0.18) - wait between firing Return and the verify pass. Too short and the verify runs before the field has reacted; too long and Kai sees a visible pause.
- `MAX_RETRIES` (2) - retries before giving up. More than 3 is usually masking a real bug.

## Debugging

`Cmd+Space` -> "Hammerspoon" -> Console opens the Lua REPL. The `print("[flow-enter] ...")` lines from `init.lua` show up there. If the auto-Return isn't firing:

- Verify the load: console should show `Flow auto-Return loaded` (from the `hs.alert.show` at the bottom).
- Watch the trigger: console should print `trigger released, polling clipboard` on Fn-up.
- Watch the paste detect: should print `fired Return` after Flow lands.
- If `timeout, no paste detected` - the trigger fired but Flow didn't actually paste within 3s. Either Flow is slow or the wrong modifier is configured.
- If `fired Return` but submission still didn't happen - the verify pass should retry; check `input still non-empty, retrying Return`. If retries exhaust silently, the app is probably swallowing Return entirely (consider adding to `BLOCKLIST` and submitting manually there).

Reload after edits: Hammerspoon menu bar -> "Reload Config". Or `hs.reload()` from the console.

## When NOT to reach for Hammerspoon

- Cross-platform keybindings - use WezTerm (`config.keys`) or the app itself if it supports it. Hammerspoon is Mac-only.
- Window management - macOS has `Rectangle` (free, fast) which is better than rolling Hammerspoon window scripts.
- Anything that runs in a shell context - that's a Nushell `def` or `coily` subcommand, not Hammerspoon.

Hammerspoon is the right reach for: OS-level event taps, accessibility-API hacks (focused-element introspection), pasteboard polling, menu-bar widgets, anything that genuinely needs `NSWorkspace` or `CGEvent` access.

## See also

- Canonical config: `~/projects/coilysiren/dotfiles/hammerspoon/init.lua`
- Install: `~/projects/coilysiren/dotfiles/README.md` (the Mac section's `ln -sf $PWD/hammerspoon/init.lua ~/.hammerspoon/init.lua`)
- Hammerspoon docs: https://www.hammerspoon.org/docs/
