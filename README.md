# agentic-os

(Formerly `coilysiren/dotfiles`. Renamed 2026-05-15 as the repo grows into broader personal-OS / agentic-OS scope beyond just shell config.)

![Sombra hacking skull](static/wallpaper.jpg)

Cross-platform shell setup. Zsh on Mac, Linux, and Windows (Git Bash). Warp is the terminal on all three, configured in-app (`~/.warp/settings.toml`), not in this repo.

A previous iteration of this repo carried Nushell + WezTerm configs. That migration was rolled back; both trees were deleted in coilysiren/agentic-os#48. Git history retains them if either ever needs to come back.

## Layout

- `zsh/zshrc` - top-level entry, symlinked to `~/.zshrc`. Sources `env.zsh`, picks the right `hosts/<os>.zsh`, then `config.zsh` and `ssm-env.zsh`.
- `zsh/env.zsh` - history, identity, editor, AWS defaults, `COILY_LOCKDOWN_ROOT`.
- `zsh/hosts/{macos,linux,windows}.zsh` - per-host PATH and tooling. Picked automatically via `uname -s`.
- `zsh/config.zsh` - aliases, git helpers, `rg` wrapper, prompt (two-line siren motif).
- `zsh/ssm-env.zsh` - in-process AWS SSM secret loader. `ssm-load` reads `/coilysiren/*` into the current shell env. Never disk.
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
mkdir -p ~/.local/bin
ln -sf "$PWD/scripts/gpg-ssm" ~/.local/bin/gpg-ssm
```

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

## What's not here (yet)

- Login-shell switching - documented above, not automated.
- Work machine config stays separate, with its own bash-script dependencies. This repo is personal-only.

## Credits

- `static/wallpaper.jpg` - Sombra hacking skull, from the [Overwatch](https://overwatch.blizzard.com) Sombra ARG promotional materials, Blizzard Entertainment, circa 2016. All Overwatch art and iconography © Blizzard Entertainment. Used here for personal terminal decoration only.
