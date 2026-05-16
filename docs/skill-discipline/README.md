# skill-discipline

Pre-commit hooks and authoring docs for Claude Code skill repositories.

## Hooks

The validators live as standalone scripts in `agentic-os/scripts/`. Each consumer repo gets a stamped copy via `agentic-os-kai/scripts/apply-skill-discipline-hooks.py` (run from agentic-os-kai with `make apply-skill-discipline-hooks`).

- `validate-skills.py` - validates `.claude/skills/` against a spec at `.claude/skills/categories.yaml`. Checks frontmatter, prefix taxonomy, status lines, required sections, size caps, stale skill-name references.
- `check-dead-links.py` - walks markdown inside `.claude/skills/`, fails if any inline `[text](path.md)` link does not resolve.
- `check-commit-closes-issue.py` - rejects commits whose message lacks a `closes #N` / `fixes #N` / `resolves #N` keyword pointing at an issue in the same repo. (Already canonical here; just listed for completeness.)

See [`examples/pre-commit-config.yaml`](examples/pre-commit-config.yaml) for the managed `.pre-commit-config.yaml` block.

## Docs

- [`handbook.md`](handbook.md) - the discipline these hooks enforce, with the why behind each rule.
- [`authoring-walkthrough.md`](authoring-walkthrough.md) - how to draft, validate, and ship a new skill.
- [`examples/categories.yaml`](examples/categories.yaml) - heavily commented spec to start from.
- [`templates/SKILL.md.template`](templates/SKILL.md.template) - minimal starter for a new skill.
