# Agent instructions

Workspace-level conventions (git workflow, voice, ops boundary) load globally via `~/.claude/CLAUDE.md` -> `coilyco-ai/AGENTS.md`. Nothing repo-specific to override yet; this file exists so the symmetric trifecta (README / AGENTS / docs/FEATURES) is complete and grep-discoverable.

## Skills

`.claude/skills/` ships SKILL.md docs for the configs that live here (`tooling-nushell`, `tooling-wezterm`, `tooling-gpg-ssm`). Coilyco-ai's `setup.sh` walks this dir as a peer skill source and symlinks each entry into `~/.claude/skills/`. Edit the SKILL.md next to the config it describes, not in coilyco-ai.

## See also

- [README.md](README.md) - human-facing intro, per-OS install steps.
- [docs/FEATURES.md](docs/FEATURES.md) - inventory of what ships today.
- [.coily/coily.yaml](.coily/coily.yaml) - allowlisted commands. No dev verbs yet; agents route through coily, not bare `make` / `uv` / `python` / `npm` / `cargo` / `dotnet`.

Cross-reference convention from [coilysiren/coilyco-ai#313](https://github.com/coilysiren/coilyco-ai/issues/313).
