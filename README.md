# agentic-os

![Sombra hacking skull](static/wallpaper.jpg)

Cross-platform shell + terminal setup. Zsh on Mac, Linux, and Windows (Git Bash). Warp on Mac and Windows; both configs (`warp/settings.toml`, `warp/tab_configs/startup_config.toml`) symlinked into `~/.warp/`.

## Layout

- `zsh/zshrc` - top-level entry, symlinked to `~/.zshrc`. Sources `env.zsh`, picks the right `hosts/<os>.zsh`, then `config.zsh` and `ssm-env.zsh`.
- `zsh/env.zsh` - history, identity, editor, AWS defaults, `COILY_LOCKDOWN_ROOT`.
- `zsh/hosts/{macos,linux,windows}.zsh` - per-host PATH and tooling. Picked automatically via `uname -s`.
- `zsh/config.zsh` - aliases, git helpers, `rg` wrapper, prompt (two-line siren motif).
- `zsh/ssm-env.zsh` - in-process AWS SSM secret loader. `ssm-load` reads `/coilysiren/*` into the current shell env. Never disk.
- `warp/settings.toml` - Warp config. Vertical tabs, theme, font, custom secret-regex list, AI/agent toggles. `[account] is_settings_sync_enabled = false` so the repo wins over cloud sync.
- `warp/tab_configs/startup_config.toml` - default new-tab pane setup.
- `scripts/` - portable utilities not specific to the shell.
  - `verbatim-echo.sh` - wrap a command's output in a fenced block clipped to 20 lines / 100 chars per line. Chat-safe dumps for mobile.
  - `check-aws-config.py` - reject the `[profile default]` trap in `~/.aws/config` that surfaces later as a cryptic `NoRegion` from SSM/S3.
  - `gpg-ssm` / `gpg-ssm.cmd` - GPG signing wrapper that pulls the passphrase from AWS SSM at `/coilysiren/gpg-passphrase/<keyid>` instead of caching it on disk. Wire-up Mac/Linux: `git config --global gpg.program "$HOME/.local/bin/gpg-ssm"`. Wire-up Windows: same but point at `gpg-ssm.cmd`, a bash.exe shim Git for Windows needs because it can't invoke extensionless shebang scripts reliably.
  - `check-commit-closes-issue.py` - commit-msg hook rejecting commits that lack a same-repo `closes #N` / `fixes #N` / `resolves #N`.
- `.claude/skills/` - SKILL.md docs for the configs that live here. `tooling-zsh`, `tooling-gpg-ssm`. agentic-os-kai's `setup.sh` walks this dir as a peer skill source, symlinking each entry into `~/.claude/skills/`. Co-located with the configs they describe so they don't drift.

## Install

### Mac

```bash
ln -sf "$PWD/zsh/zshrc" ~/.zshrc
mkdir -p ~/.warp/tab_configs ~/.local/bin
ln -sf "$PWD/warp/settings.toml" ~/.warp/settings.toml
ln -sf "$PWD/warp/tab_configs/startup_config.toml" ~/.warp/tab_configs/startup_config.toml
ln -sf "$PWD/scripts/gpg-ssm" ~/.local/bin/gpg-ssm
```

(After symlinking Warp settings, restart Warp once so it re-reads. If a UI toggle silently snaps back to default, check that `[account] is_settings_sync_enabled` is still `false` - cloud sync will overwrite the symlink target.)

Login shell defaults to `/bin/zsh`. If a previous shell-switch needs undoing:

```bash
chsh -s /bin/zsh
```

### Linux (kai-server)

```bash
ln -sf "$PWD/zsh/zshrc" ~/.zshrc
mkdir -p ~/.local/bin
ln -sf "$PWD/scripts/gpg-ssm" ~/.local/bin/gpg-ssm
chsh -s "$(which zsh)"
```

### Windows (Git Bash)

zsh inside Git Bash is installed via the MSYS environment (`pacman -S zsh`). Symlinks under Git Bash use POSIX paths.

```bash
ln -sf "$PWD/zsh/zshrc" ~/.zshrc
mkdir -p ~/.local/bin
ln -sf "$PWD/scripts/gpg-ssm.cmd" ~/.local/bin/gpg-ssm.cmd
```

(Symlinks need either an elevated Git Bash or Settings -> Privacy and Security -> For developers -> Developer Mode toggled on.)

## Secrets pattern

The legacy pattern wrote all SSM SecureStrings to `~/.cache/ssm-env.sh` and sourced it from `.zshenv`. That cleartext-on-disk dump was deleted.

The current pattern:

```bash
ssm-load                          # pull every / parameter into the current shell env
ssm-get /eco/server-api-token     # fetch one value without storing it
```

No disk write at any point. Same call works on Mac, Linux, Windows. AWS profile defaults to `default`; override with `ssm-load <profile> <region>`.

If you want secrets at shell startup, append `ssm-load` to the end of `zsh/config.zsh`. Default behavior is opt-in per shell.

## Credits

- `static/wallpaper.jpg` - Sombra hacking skull, from the [Overwatch](https://overwatch.blizzard.com) Sombra ARG promotional materials, Blizzard Entertainment, circa 2016. All Overwatch art and iconography © Blizzard Entertainment. Used here for personal terminal decoration only.
