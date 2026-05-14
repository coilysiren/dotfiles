# Features

Baseline inventory of what `dotfiles` ships today. Use this as the reference point for scope changes. When a feature is added, removed, or materially reshaped, update the relevant section so the diff against this file shows scope drift over time.

Last full sweep: 2026-05-13.

## Nushell config

Cross-platform nu startup files, symlinked into the OS-specific nu config dir at install time.

- **[nu/env.nu](../nu/env.nu)** - sourced first at startup. Sets `LANG`, `EDITOR`, `GIT_EDITOR`, `SSH_KEY_PATH`, `CLI_MFA`, `AWS_PROFILE`, `AWS_REGION`, `AWS_PAGER`, `COILY_LOCKDOWN_ROOT`. Then sources the matching host file.
- **[nu/config.nu](../nu/config.nu)** - aliases (`del`, `..`, `gt`, `gush`), a wrapped `rg` with hidden-file globs, ported git helpers (`git-default-branch`, `git-pr-title`, `git-merge-default-branch`, `git-checkpoint`, `git-squash`, `gt-conflicts`), Docker helper (`docker-bash`), `pull-all-repos`, `count-lines`, `github-token-load`. Imports `ssm-env.nu`.
- **[nu/hosts/macos.nu](../nu/hosts/macos.nu)** - Mac PATH (homebrew, cargo, ruby, openjdk, gradle, dotnet, fabro), `JAVA_HOME`, `NODE_EXTRA_CA_CERTS` for the local Caddy root.
- **[nu/hosts/linux.nu](../nu/hosts/linux.nu)** - Linux PATH (linuxbrew, cargo, local bins). Designed for kai-server.
- **[nu/hosts/windows.nu](../nu/hosts/windows.nu)** - Windows PATH (Git Bash, cargo, local bins).

Per-host file is picked at startup via `$nu.os-info.name`, so no manual branching.

## In-process AWS SSM secret loader

[nu/ssm-env.nu](../nu/ssm-env.nu) provides two exported commands:

- **`ssm-load`** - pulls every SSM SecureString under `/` from the named profile (defaults to `default`, `us-east-1`) and `load-env`s them into the current nu process. Var name derivation matches the legacy script: `/foo/bar-baz` -> `FOO_BAR_BAZ`. Never writes to disk.
- **`ssm-get <name>`** - fetches a single parameter value, prints it, no disk write.

Replaces the prior `~/.cache/ssm-env.sh` cleartext dump (deleted) and its `scripts/ssm-export-lines.sh` generator (also deleted).

## WezTerm config

[wezterm/wezterm.lua](../wezterm/wezterm.lua) - single Lua config used on all three OSes. Symlinked to `~/.wezterm.lua` on Mac/Linux and `%USERPROFILE%\.wezterm.lua` on Windows.

- **Cross-platform nu resolution** - walks `/opt/homebrew/bin/nu`, `/usr/local/bin/nu`, `~/.cargo/bin/nu`, `/home/linuxbrew/.linuxbrew/bin/nu`, falls back to bare `nu` on PATH.
- **Launch menu** - per-OS shell picker. Windows: Nushell / Git Bash / PowerShell 7 / PowerShell 5 / cmd. Mac: Nushell / zsh / bash. Linux: Nushell / bash. Bound to `Ctrl+Shift+Space`.
- **Startup window state** - `gui-startup` event handler. On macOS, native fullscreen (own Mission Control Space) via `native_macos_fullscreen_mode = true`. On Linux/Windows, maximize.
- **Background image** - dimmed Sombra hacking skull wallpaper from [static/wallpaper.jpg](../static/wallpaper.jpg). Brightness 0.08, saturation 0.7. Path resolves per-OS to the dotfiles checkout.
- **Fonts** - Monaspace family bundled in [wezterm/fonts/](../wezterm/fonts/) so the config is self-contained across hosts. Per-attribute style swap: Neon (regular), Radon (italic / comments), Xenon (bold), Krypton (bold-italic), Light variant for half-intensity. `font_dirs` is additive so system emoji/glyph fallback still works.
- **Theme + chrome** - Tokyo Night, 13pt, 50k scrollback, audible bell disabled, no close-window confirmation, `RESIZE`-only window decorations.

## Install surface

[README.md](../README.md) carries per-OS install steps. Mac and Linux use symlinks; Windows uses copy (symlinks need admin/dev mode).
