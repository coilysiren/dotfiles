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

## Host portability

One line is host-absolute and will not work cross-platform as-written:

- `[general] default_tab_config_path = "/Users/kai/.warp/tab_configs/startup_config.toml"`

On Windows, this needs to be `C:\Users\kai\.warp\tab_configs\startup_config.toml`. Two options for handling this when it comes up:

1. Per-host override - leave Mac path in repo, edit Windows copy in place after symlinking (breaks the symlink-as-source-of-truth model).
2. Drop `default_tab_config_path` entirely - Warp falls back to a default new-tab. Re-add only if the named startup tab is load-bearing.

Until Kai installs on Windows, leave the Mac path as-is.

## Tabs as the navigation primitive

Vertical tabs (`[appearance.vertical_tabs] enabled = true`) is the load-bearing UI choice. Block-mode terminal + tab-as-context-anchor is why Warp lives. When tweaking the file, do not regress these:

- `enabled = true`
- `primary_info = "working_directory"` - tab label shows cwd, not command
- `compact_subtitle = "command"` - last command as subtitle
- `view_mode = "compact"` - dense list, more tabs visible
- `display_granularity = "panes"` - one row per pane, not per tab

## AI / Agent surface

Warp ships several AI surfaces. Kai uses Claude Code for AI work; Warp doesn't need to be a second one. Knobs to watch when noise comes back:

- `[agents.profiles] agent_mode_execute_readonly_commands` - Warp will auto-run readonly commands. Currently on. Off if surprise-execution is unwanted.
- `[agents.warp_agent.input] ai_auto_detection_enabled` - Warp guesses when input is natural-language vs command. Currently on.
- `[agents.warp_agent.input] nld_in_terminal_enabled` - natural language dispatcher in the prompt.
- `[code.indexing] agent_mode_codebase_context_auto_indexing` - Warp indexes the repo for AI context.
- `[agents] cloud_conversation_storage_enabled` - if Warp AI is used, conversations go to Warp's cloud.
- `[general] default_session_mode` - "terminal" (current) or "agent". Keep terminal so a new tab is a shell, not a chat surface.

Flipping all of these off in one pass is the obvious noise-cut; doing it surgically gives a smaller noise reduction with less feature loss. See the noise-reduction recon thread.

## Common edits

- **Theme** - `[appearance.themes] theme = "phenomenon"`. Other built-ins live under Warp's Settings > Appearance.
- **Font size** - `[appearance.text] font_size = 11.0` and `notebook_font_size = 14.0`.
- **Custom secret regexes** - `[privacy] custom_secret_regex_list` is a TOML array of `{ name, pattern }` tables. Patterns are detection-only (block redaction is off, see `[privacy.secret_redaction] enabled = false`).
- **Subshell auto-warpify** - `[warpify.subshells] added_subshell_commands` makes Warp render blocks for commands like `docker compose run` that drop into an inner shell.
