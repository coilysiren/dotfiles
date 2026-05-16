#!/usr/bin/env python3
"""Enforce the catalog-trifecta cross-link convention.

Every catalog repo carries three audience-distinct entry-point markdown
files at the root plus the coily command spec. Each markdown file
cross-links to the other two plus to the YAML. This makes the entry
point reachable from any one of them with a single click.

The four files:
    README.md           - pitch + quick start for human readers
    AGENTS.md           - per-repo agent operating rules
    docs/FEATURES.md    - flat inventory of what ships today
    .coily/coily.yaml   - allowlisted dev commands

This validator checks, per markdown file:
    1. The file exists.
    2. The file contains a "## See also" section header.
    3. The file contains markdown links resolving to each of the other
       three canonical paths (the two peer .md files plus .coily/coily.yaml).
    4. The file cites the canonical convention doc - either the new home
       at coilysiren/agentic-os#59 or the legacy home at
       coilysiren/agentic-os-kai#313 (during the migration window).

The .coily/coily.yaml file only needs to exist; no back-link required,
since YAML is machine-consumed and the prose home is the .md files.

Usage (when run directly):
    python3 scripts/check-catalog-trifecta.py

Canonical copy lives in coilysiren/agentic-os/scripts/. Each consumer
repo gets a stamped copy via agentic-os-kai's apply-catalog-trifecta-hook
rollout. Exits 0 on clean, 1 on any violation with a per-file report on
stderr.

See coilysiren/agentic-os#59 for the convention design.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

REPO_ROOT = Path.cwd()

# Markdown files where the See also section lives.
MD_FILES = [
    Path("README.md"),
    Path("AGENTS.md"),
    Path("docs/FEATURES.md"),
]

# The fourth member of the cross-link group. Existence-only check;
# linked from the .md files but does not link back.
COILY_YAML = Path(".coily/coily.yaml")

SEE_ALSO_HEADER = re.compile(r"^##\s+See also\s*$", re.MULTILINE)

# Markdown inline link target extraction. Mirrors the form used by
# check-dead-links.py so the two validators agree on what a "link" is.
LINK_RE = re.compile(
    r"(?<!\!)\[(?P<text>[^\]\n]+)\]\((?P<target>[^)\s]+)(?:\s+\"[^\"]*\")?\)"
)

CONVENTION_CITATIONS = (
    "coilysiren/agentic-os#59",
    "coilysiren/agentic-os-kai#313",
)


def link_targets(text: str) -> set[str]:
    """Resolved-target paths for every inline markdown link in `text`.

    Strips anchor fragments. Returns relative paths as-is (no resolution
    against any base dir); resolution happens in the caller.
    """
    out: set[str] = set()
    for m in LINK_RE.finditer(text):
        target = m.group("target").split("#", 1)[0].strip()
        if target:
            out.add(target)
    return out


def file_links_to(source_path: Path, target_path: Path, body: str) -> bool:
    """True if body contains a markdown link whose resolved target equals
    target_path (relative to repo root)."""
    targets = link_targets(body)
    source_dir = (REPO_ROOT / source_path).parent
    for t in targets:
        candidate = (source_dir / t).resolve()
        try:
            rel = candidate.relative_to(REPO_ROOT.resolve())
        except ValueError:
            continue
        if rel == target_path:
            return True
    return False


def check_md_file(md_path: Path) -> list[str]:
    violations: list[str] = []
    abs_path = REPO_ROOT / md_path

    if not abs_path.is_file():
        violations.append(f"{md_path}: missing. Trifecta requires this file at the canonical path.")
        return violations

    body = abs_path.read_text(encoding="utf-8", errors="replace")

    if not SEE_ALSO_HEADER.search(body):
        violations.append(f"{md_path}: missing '## See also' section header.")

    peers = [p for p in MD_FILES if p != md_path] + [COILY_YAML]
    for peer in peers:
        if not file_links_to(md_path, peer, body):
            violations.append(
                f"{md_path}: no markdown link resolves to {peer}. "
                f"The 'See also' section must point at the other three "
                f"catalog-trifecta files."
            )

    if not any(c in body for c in CONVENTION_CITATIONS):
        violations.append(
            f"{md_path}: convention citation missing. Include "
            f"'coilysiren/agentic-os#59' (or the legacy "
            f"'coilysiren/agentic-os-kai#313') in the See also footer."
        )

    return violations


def check_coily_yaml() -> list[str]:
    if not (REPO_ROOT / COILY_YAML).is_file():
        return [f"{COILY_YAML}: missing. Required for the catalog-trifecta group."]
    return []


def main() -> int:
    all_violations: list[str] = []
    for md in MD_FILES:
        all_violations.extend(check_md_file(md))
    all_violations.extend(check_coily_yaml())

    if not all_violations:
        print("catalog-trifecta check: OK")
        return 0

    for v in all_violations:
        sys.stderr.write(f"FAIL: {v}\n")
    sys.stderr.write(f"\n{len(all_violations)} violation(s). See coilysiren/agentic-os#59.\n")
    return 1


if __name__ == "__main__":
    sys.exit(main())
