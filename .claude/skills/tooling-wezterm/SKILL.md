---
name: tooling-wezterm
description: WezTerm is Kai's terminal on every host. Single cross-platform wezterm.lua. Use when editing terminal config, debugging fonts, changing color scheme, tweaking the launcher menu, adding key bindings, or shipping a change that must work on all three OSes. Triggers - wezterm, wezterm.lua, terminal config, font_dirs, Monaspace, Neon, Radon, Xenon, Krypton, Tokyo Night, native_macos_fullscreen, launch_menu, default_prog, target_triple.
---

# WezTerm

Kai's terminal on every host. One config file, three OSes.

## Config location

Canonical file: `~/projects/coilysiren/agentic-os/wezterm/wezterm.lua`. Symlinked to:

- **Mac/Linux** - `~/.wezterm.lua`
- **Windows** - `%USERPROFILE%\.wezterm.lua`

Fonts ship in-repo at `wezterm/fonts/` (Monaspace variable TTFs). Wallpaper at `static/wallpaper.jpg`. Both paths resolve via `wezterm.home_dir` plus the host-specific prefix (`/projects/coilysiren/agentic-os` on Mac/Linux, `\projects-x\coilysiren\agentic-os` on Windows).

## Platform branching

Branch with `wezterm.target_triple:find('darwin' | 'windows' | 'linux')`. Existing branches:

- **Mac** - `native_macos_fullscreen_mode = true`, `gui-startup` toggles fullscreen so WezTerm gets its own Mission Control Space. Launch menu includes Nushell + zsh + bash.
- **Linux** - Launch menu: Nushell + bash. Maximized window on startup, not fullscreen.
- **Windows** - `default_cwd` is `\projects-x\coilysiren`. Launch menu has the full shell picker: Nushell, Git Bash, PowerShell 7, PowerShell 5, cmd. Maximized.

## Fonts

Monaspace variable family. Each attribute combo maps to a different sibling face designed by githubnext to share metrics:

- regular -> Monaspace **Neon** (neo-grotesque)
- italic -> Monaspace **Radon** (handwriting) - mostly comments
- bold -> Monaspace **Xenon** (slab)
- bold-italic -> Monaspace **Krypton**
- light/half-intensity -> Monaspace Neon Light

Wired via `config.font` + `config.font_rules`. Size 13.0.

**Critical gotcha** - `config.font_dirs = { fonts_dir() }` is **additive**. Never set `font_locator = 'ConfigDirsOnly'` - that breaks system-font fallback for emoji and missing glyphs. Comment in the file already says this, don't undo it.

If a glyph renders as tofu, fix is almost always one of: missing TTF in `wezterm/fonts/`, broken symlink, or someone (you) set `font_locator`. Check those before suspecting WezTerm.

## Color scheme

`Tokyo Night`. Built-in, no external file. To change, replace the literal string; `wezterm ls-fonts --list-system` shows what's available but for color schemes use `wezterm show-keys --lua` or the upstream gallery.

## Default shell

`config.default_prog = { nu }` on every OS.

On Mac/Linux a `find_nu()` helper walks candidate paths (`/opt/homebrew/bin/nu`, `/usr/local/bin/nu`, `~/.cargo/bin/nu`, `/home/linuxbrew/.linuxbrew/bin/nu`) and returns the first match, falling back to bare `nu`. If a fresh host can't find Nushell, either install via brew or add the new candidate path to that helper.

On Windows it's bare `nu` (assumes Nushell is on PATH).

## Key bindings

Minimal set in `config.keys`:

- `Ctrl+Shift+Space` - `ShowLauncher` (the shell picker menu).
- `Cmd+T` - new tab in current pane domain.
- `Cmd+W` - close current tab without confirmation.

`hide_tab_bar_if_only_one_tab = true`, `use_fancy_tab_bar = false`, `window_decorations = 'RESIZE'`, `audible_bell = 'Disabled'`, `window_close_confirmation = 'NeverPrompt'`, `scrollback_lines = 50000`. These are all deliberate. Don't second-guess without asking.

## Reloading

WezTerm auto-reloads `wezterm.lua` on save. Errors surface in the WezTerm debug overlay (`Ctrl+Shift+L`) - check there if a config change doesn't seem to take. Syntax errors keep the previous config running, so a broken save doesn't lock Kai out.

## Common edits

- **Add a key binding** - append to `config.keys` table with `{ key = '...', mods = '...', action = wezterm.action.<...> }`.
- **Add a shell to the launcher** - append to the appropriate `config.launch_menu` branch (Mac, Linux, or Windows).
- **Change default cwd** - edit the two `default_cwd` branches in lockstep. Don't unify them - the Windows path is structurally different (`\projects-x\` not `/projects/`).
- **Change background opacity** - tweak `hsb.brightness` (currently `0.08`) and `saturation` (currently `0.7`) on the wallpaper layer.

## When NOT to use WezTerm config

- Per-shell prompt config goes in Nushell (`config.nu`), not here. See [`tooling-nushell`](../tooling-nushell/SKILL.md).
- Environment variables go in Nushell `env.nu` or per-host `hosts/*.nu`. WezTerm shouldn't be a global env-var pusher.
- Login-shell selection (`chsh`) is OS-level, not WezTerm-level. WezTerm's `default_prog` overrides it for WezTerm windows only.

## See also

- Canonical config: `~/projects/coilysiren/agentic-os/wezterm/wezterm.lua`
- Fonts: `~/projects/coilysiren/agentic-os/wezterm/fonts/`
- Install snippets: `~/projects/coilysiren/agentic-os/README.md`
- Shell that runs inside it: [`tooling-nushell`](../tooling-nushell/SKILL.md)
- Mac fullscreen-Space behavior origin: `gui-startup` handler at the top of `wezterm.lua`
