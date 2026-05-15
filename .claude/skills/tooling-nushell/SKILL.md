---
name: tooling-nushell
description: Nushell is the user's default shell on every host. Syntax is not bash/zsh-compatible. Use when drafting shell commands, editing agentic-os/nu/*, configuring PATH or prompt, loading AWS secrets via ssm-load, or debugging unfamiliar nu errors. Triggers - nushell, nu, $env.VAR, $nu.os-info, structured pipeline, let, def, ssm-load, ssm-env, env.nu, config.nu, hosts/macos.nu, PROMPT_COMMAND, chsh nu.
---

# Nushell

the user's shell on every host. Drafted commands should be Nushell unless asked otherwise.

## Config location

Canonical files live at `~/projects/coilysiren/agentic-os/nu/`, symlinked into Nushell's config dir per OS:

- **Mac** - `~/Library/Application Support/nushell/` (not `~/.config/nushell/`). AGENTS.md gets this wrong - check the agentic-os README for the install snippet, never re-derive.
- **Linux** - `~/.config/nushell/`.
- **Windows** - `%APPDATA%\nushell\`.

Resolve generically via `$nu.default-config-dir` inside Nushell code.

Files:

- `env.nu` - runs first. Sets `$env.LANG`, `$env.EDITOR`, AWS defaults, `$env.COILY_LOCKDOWN_ROOT`, then `source`s `hosts/($nu.os-info.name).nu` for per-OS PATH.
- `config.nu` - aliases, `def`s (git helpers, rg wrapper, etc.), the two-line prompt with siren motif, `use ssm-env.nu *`.
- `hosts/{macos,linux,windows}.nu` - per-OS PATH and tooling.
- `ssm-env.nu` - in-process AWS SSM secret loader. `ssm-load` reads `/coilysiren/env/*` into `$env` for the current session only. Never disk.

## Syntax gotchas

The bash/zsh reflex is wrong roughly 50% of the time. The pattern, the right Nushell shape:

- `$VAR` -> `$env.VAR`. Local variable: `let foo = "bar"` (immutable). Mutable: `mut foo = ...`.
- `export FOO=bar` -> `$env.FOO = "bar"` (or `$env.FOO = "bar"` inside `def --env`).
- `FOO=bar cmd` -> `with-env { FOO: "bar" } { cmd }`.
- `cmd1 && cmd2` -> `cmd1; cmd2` for unconditional, `if (cmd1 | complete | get exit_code) == 0 { cmd2 }` for conditional. There is no `&&` / `||`.
- `cmd1 || cmd2` -> same `if` shape, inverted.
- `$(cmd)` / backticks -> `(cmd)` inline, or `let x = (cmd)`.
- Pipes carry structured data, not bytes. `ls` returns a table, not lines. To force string/bytes mode for an external command, prefix with `^`: `^git status`, `^rg foo`.
- Stderr+stdout merging: `cmd | complete` returns a record with `stdout`, `stderr`, `exit_code`. Use this instead of `2>&1`.
- String interpolation: `$"hello ($name)"`. Single-quoted strings don't interpolate.
- Globs are not auto-expanded by externals. `^rg --glob '!.git' ...` works; bare `*.py` does not. Use `glob` to expand explicitly.
- No `~` in string literals for external commands. Use `$nu.home-dir` or `($env.HOME)`.
- Function args are typed and positional by default: `def foo [name: string, --flag] { ... }`. Rest params: `def foo [...args] { ^cmd ...$args }`.
- Aliases can't shadow externals the way zsh aliases can. To override `rg`, write `def rg [...args] { ^rg --hidden ...$args }`.
- `cd` inside a function doesn't escape. To change the caller's cwd, use `def --env`.
- No `&&`/`||` in `if` either. Use `and` / `or` keywords: `if $a and $b { ... }`.

## Running externals

Prefix with `^` whenever a name collides with a Nushell builtin or when you want the raw external (not the structured wrapper). Always for: `^git`, `^rg`, `^gh`, `^docker`, `^aws`, `^kubectl`. Optional but recommended even when no collision exists - it makes the intent explicit and survives future builtin additions.

## Prompt

Two-line prompt defined in `config.nu`. Line 1: `🕐 HH:MM:SS  🧜 user@host  📂 cwd  ⚓ branch ✨  💥 N`. Line 2: `$`. Hooks: `$env.PROMPT_COMMAND`, `$env.PROMPT_INDICATOR`. No starship dependency. If editing the prompt, keep the dirty-tree marker (`✨`) and the non-zero-exit marker (`💥 N`).

## AWS SSM secrets

`ssm-env.nu` exposes `ssm-load`. Pulls `/coilysiren/env/*` SecureString params via `aws ssm get-parameters-by-path --with-decryption` and writes them to `$env` in-process. Nothing hits disk. Old behavior (`~/.cache/ssm-env.sh` cleartext dump) is gone - don't reintroduce.

`def --env` is required so the assignments leak to the caller. Without it the env mutations vanish when the function returns.

## Login shell

`chsh -s "$(nu | path expand)"` after adding to `/etc/shells`. On Mac the install snippet in the agentic-os README is authoritative. On Linux Nushell is invoked bare by WezTerm; not setting it as login shell is also fine.

## When to drop to bash

- One-liners over SSH that need POSIX compatibility on a host that doesn't have Nushell installed.
- Inside `Makefile` recipes, GitHub Actions `run:` blocks, pre-commit hooks. Those execute in `/bin/sh` or `bash` - Nushell syntax will silently fail.
- Heredocs - Nushell doesn't have a clean heredoc equivalent yet. Write the file with `Write` or use `echo "..." | save file.txt`.

For everything else, draft in Nushell.

## Common nu commands worth remembering

- `ls | where size > 1mb | sort-by modified` - structured filtering.
- `open file.yaml | get key.subkey` - typed access to YAML/JSON/TOML.
- `^cmd | complete` - capture stdout/stderr/exit_code as a record.
- `do { ^cmd } | complete` - same, but for a pipeline.
- `def foo [] { ... }` - one-shot function. `def --env foo [] { ... }` if it mutates `$env`.
- `help <topic>` - built-in help. `help commands | where name =~ "git"` is a good discovery move.

## See also

- Canonical configs: `~/projects/coilysiren/agentic-os/nu/`
- Install snippets per OS: `~/projects/coilysiren/agentic-os/README.md`
- Terminal that runs Nushell: [`tooling-wezterm`](../tooling-wezterm/SKILL.md)
