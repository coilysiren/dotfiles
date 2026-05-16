# Features

Baseline of what `agentic-os` ships today. Update when a feature is added, removed, or materially reshaped.

## Nushell config

Cross-platform nu startup files, symlinked into the OS-specific nu config dir at install time.

- **[nu/env.nu](../nu/env.nu)** - sourced first at startup. Sets `LANG`, `EDITOR`, `GIT_EDITOR`, `SSH_KEY_PATH`, `CLI_MFA`, `AWS_PROFILE`, `AWS_REGION`, `AWS_PAGER`, `COILY_LOCKDOWN_ROOT`. Then sources the matching host file.
- **[nu/config.nu](../nu/config.nu)** - aliases, a wrapped `rg` with hidden-file globs, ported git helpers (`git-default-branch`, `git-pr-title`, `git-merge-default-branch`, `git-checkpoint`, `git-squash`), `docker-bash`, `pull-all-repos`, `github-token-load`. Imports `ssm-env.nu`.
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
- **Background image** - dimmed Sombra hacking skull wallpaper from [static/wallpaper.jpg](../static/wallpaper.jpg). Brightness 0.08, saturation 0.7. Path resolves per-OS to the agentic-os checkout.
- **Fonts** - Monaspace family bundled in [wezterm/fonts/](../wezterm/fonts/). Per-attribute style swap (Neon/Radon/Xenon/Krypton). `font_dirs` additive so system emoji fallback still works.
- **Theme + chrome** - Tokyo Night, 13pt, 50k scrollback, audible bell disabled, no close-window confirmation, `RESIZE`-only window decorations.

## Install surface

[README.md](../README.md) carries per-OS install steps. Mac and Linux use symlinks; Windows uses copy (symlinks need admin/dev mode).

## Diagnostic scripts

- **[scripts/gpg-doctor.nu](../scripts/gpg-doctor.nu)** - walks every check needed to diagnose `gpg failed to sign the data` from a `git commit`. Verifies binaries, gpg-agent socket, git config, secret-key presence, optional YubiKey, then runs a real sign test. Names the most-likely fix for each failure mode. Run with `nu scripts/gpg-doctor.nu`.

## Portable utility scripts

Generic scripts hoisted out of `agentic-os-kai/scripts/`. Originals stay there for now to keep its setup.sh and commit-hook rollout working.

- **[scripts/verbatim-echo.sh](../scripts/verbatim-echo.sh)** - run a command and emit its output wrapped in a fenced code block, clipped to 20 lines / 100 chars per line. Used by the `$$ <cmd>` chat convention so mobile chat sees command output without blowing the context window.
- **[scripts/check-aws-config.py](../scripts/check-aws-config.py)** - lint `~/.aws/config` for the `[profile default]` trap. AWS SDKs read `[default]`, not `[profile default]`; misplaced `region =` surfaces later as a cryptic `NoRegion` from SSM/S3.
- **[scripts/gpg-ssm](../scripts/gpg-ssm)** / **[scripts/gpg-ssm.cmd](../scripts/gpg-ssm.cmd)** - GPG signing wrapper. Pulls the passphrase from AWS SSM at `/coilysiren/gpg-passphrase/<keyid>` rather than cache-to-disk. Per-host signing key contains stolen-laptop blast radius. Wire-up: `git config --global gpg.program "$HOME/.local/bin/gpg-ssm"` on Mac/Linux; `.cmd` shim on Windows.
- **[scripts/check-commit-closes-issue.py](../scripts/check-commit-closes-issue.py)** - commit-msg pre-commit hook. Rejects commits that lack a same-repo GitHub closing keyword (`closes #N` / `fixes #N` / `resolves #N`, case-insensitive).
