---
name: tooling-warp
description: Warp is Kai's terminal on every host. Block-mode shell with left-side vertical tabs. Config at ~/.warp/settings.toml, symlinked into agentic-os/warp/. Use when editing Warp config, debugging UI noise, adjusting tab behavior, configuring shells per-OS, or tuning Warp AI/agent surfaces. Triggers - warp, Warp, ~/.warp, warp settings, settings.toml, vertical tabs, warp tabs, launch configuration, warp blocks, warp ai, warp agent, warpify, subshell, tab config, startup_config.
---

# Warp

The terminal on every host. Block-mode UI with left-side vertical tabs.

## Config location

Canonical files live at `~/projects/coilysiren/agentic-os/warp/`, symlinked into `~/.warp/`:

- `~/.warp/settings.toml` -> `agentic-os/warp/settings.toml`
- `~/.warp/tab_configs/startup_config.toml` -> `agentic-os/warp/tab_configs/startup_config.toml`

## Cloud-sync gotcha

`[account] is_settings_sync_enabled` is forced to `false` in the committed copy. If Warp's cloud settings-sync is on, it overwrites the symlink target on every settings-touch from any device, fighting the repo. The repo wins; cross-device sync is given up on purpose.

If a settings-pane toggle silently disappears the next time Warp restarts, suspect cloud-sync was flipped back on and check `[account]` in the file.

## Why Warp instead of a classic terminal

Two pieces, together. Don't regress either:

- **Block-mode terminal.** Each command groups with its output as a discrete block. Click any past block to copy, share, or jump back. Errors get a red gutter. Long output collapses. This is the main reason Warp exists.
- **Tab as session anchor.** Each vertical tab keeps its own cwd, scrollback, env, and running processes. Switching tabs is switching context, not re-typing it. Like browser tabs for shell sessions.

The unit of work is a block, the unit of context is a tab.

## Tab discipline

Kai's typical Warp session is 4-7 tabs, one shell per tab, no splitting:

- 1 plain shell (true blank canvas).
- 1 file viewer (running `bat`-wrapped reflexes, see coilysiren/agentic-os#57).
- 1 status watcher (running `watch -n 5 '<command>'` for health checks).
- 4 cloud agents (typically Claude Code sessions).
- Optional: 1 persistent `ssh kai-server` tab if homelab work is hot.

Panes are off. Splitting one tab into multiple panes is rejected as a navigation primitive; if a status display is needed, it gets its own tab. This is why `display_granularity = "tabs"` (not `"panes"`).

## Settings that must not regress

In `[appearance.vertical_tabs]`:

- `enabled = true` - vertical tabs on. The whole UX bet.
- `primary_info = "process"` - tab label is the running process (`claude`, `zsh`, `code`, `ssh`). cwd is useless because Kai is in `~/projects/coilysiren/*` 95% of the time.
- `compact_subtitle = "command"` - last command as subtitle line under the process. Two layers of info per tab row.
- `view_mode = "compact"` - dense list. Open question whether to flip to non-compact at 6-tab average; revisit if rows look too dense.
- `display_granularity = "tabs"` - one row per tab, not per pane. Panes are off.

## Host portability

One line is host-absolute and will not work cross-platform as-written:

- `[general] default_tab_config_path = "/Users/kai/.warp/tab_configs/startup_config.toml"`

On Windows, this needs `C:\Users\kai\.warp\tab_configs\startup_config.toml`. Two options when Windows comes up:

1. Per-host override - leave Mac path in repo, edit Windows copy in place after symlinking (breaks the symlink-as-source-of-truth model).
2. Drop `default_tab_config_path` entirely - Warp falls back to a default new-tab. Re-add only if the named startup tab is needed.

Until Kai installs on Windows, leave the Mac path as-is.

## AI / Agent surface (the noise-cut)

Warp ships several AI surfaces. Kai uses Claude Code for AI work; Warp is terminal-only. Five of six knobs flipped off via the file (verified by quit/relaunch loop in coilysiren/agentic-os#56):

- `[agents.profiles] agent_mode_execute_readonly_commands = false`
- `[agents.warp_agent.input] ai_auto_detection_enabled = false`
- `[agents.warp_agent.input] nld_in_terminal_enabled = false`
- `[code.indexing] agent_mode_codebase_context_auto_indexing = false`
- `[general] default_session_mode = "terminal"` - new tab is a shell, not a chat surface.

The sixth, `[agents] cloud_conversation_storage_enabled`, is the one knob that resists file-edits. Warp writes `true` back to the file on every cold launch, regardless of what the file says and regardless of `is_settings_sync_enabled = false`. Account-state has its own source of truth that overrides. **To actually disable it, toggle the corresponding option in Warp's UI (Settings > AI > Conversation storage or similar).** Warp will then write `false` to both its internal state and the file, and the file will stop being overwritten.

Open question: whether Warp has a hard kill-switch for the agent-panel keyboard shortcut (Cmd+I or similar). If not, the next-best mitigation is rebinding it to nothing in Settings > Keyboard. Verify in the real UI.

## settings.toml schema gotchas

Enums in this file are strict-validated against Rust enum variants in the Warp binary. Wrong values get a `Failed to parse file value for setting <Name>` error in `~/Library/Logs/warp.log` and an `Inhibiting writes for setting key <key>` follow-up, after which Warp ignores the file's value entirely. Recovery is to fix the value and relaunch.

To find valid enum variants without docs, grep the binary:

```bash
strings /Applications/Warp.app/Contents/MacOS/stable | grep -oE '<EnumName>[A-Z][a-zA-Z]*' | sort -u
```

For example, `VerticalTabsPrimaryInfo` resolves to `{Command, WorkingDirectory, Branch}` (serialized as snake_case in TOML: `command`, `working_directory`, `branch`). Do not guess. `primary_info = "process"` is not a valid value and Warp will reject it.

## Inline rich rendering

Warp renders:

- Clickable URLs and clickable file paths in output (OSC 8 hyperlinks).
- Images via the iTerm2 inline image protocol. So `imgcat foo.png` shows the image in the block.
- Pretty-printed tables when output is structured (e.g. `ls -l`).

The `open` wrapper in coilysiren/agentic-os#57 routes image extensions to `imgcat` and falls back to `command open` for everything else. `chafa` is the universal terminal image/video renderer if Warp's native protocol doesn't cover a case.

Less sure: whether Warp renders raw markdown in shell-mode output (agent panel definitely does). Verify when relevant.

## Common edits

- **Theme** - `[appearance.themes] theme = "phenomenon"`. Other built-ins live under Warp's Settings > Appearance.
- **Font size** - `[appearance.text] font_size = 11.0` and `notebook_font_size = 14.0`.
- **Custom secret regexes** - `[privacy] custom_secret_regex_list` is a TOML array of `{ name, pattern }` tables. Patterns are detection-only (block redaction is off, see `[privacy.secret_redaction] enabled = false`).
- **Subshell auto-warpify** - `[warpify.subshells] added_subshell_commands` makes Warp render blocks for commands like `docker compose run` that drop into an inner shell.

## See also

- coilysiren/agentic-os#57 - terminal file-viewer wrapper functions (`bat`, `view`, `open`, etc.).
- coilysiren/agentic-os#58 - Brewfile catalog of modern CLI tools.
