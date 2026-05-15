# Agent instructions

Workspace-level conventions (git workflow, voice, ops boundary) load globally via `~/.claude/CLAUDE.md` -> `agentic-os-kai/AGENTS.md`. Nothing repo-specific to override yet; this file exists so the symmetric trifecta (README / AGENTS / docs/FEATURES) is complete and grep-discoverable.

## Skills

`.claude/skills/` ships SKILL.md docs for the configs that live here (`tooling-zsh`, `tooling-gpg-ssm`). agentic-os-kai's `setup.sh` walks this dir as a peer skill source and symlinks each entry into `~/.claude/skills/`. Edit the SKILL.md next to the config it describes, not in agentic-os-kai. (`tooling-nushell` and `tooling-wezterm` are scheduled for deletion alongside the nu/ and wezterm/ trees - see coilysiren/agentic-os#48.)

## See also

- [README.md](README.md) - human-facing intro, per-OS install steps.
- [docs/FEATURES.md](docs/FEATURES.md) - inventory of what ships today.
- [.coily/coily.yaml](.coily/coily.yaml) - allowlisted commands. No dev verbs yet; agents route through coily, not bare `make` / `uv` / `python` / `npm` / `cargo` / `dotnet`.

Cross-reference convention from [coilysiren/agentic-os-kai#313](https://github.com/coilysiren/agentic-os-kai/issues/313).
