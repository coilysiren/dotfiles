#!/usr/bin/env python3
"""Cap the size of README.md, AGENTS.md, and docs/FEATURES.md in catalog repos.

These three files get pulled wholesale into `agentic-os-kai/data/repo-digests/`
by a daily compiler so agents working from agentic-os-kai's project context
have visibility into every sibling repo. The compiler does no truncation;
size discipline lives at the source so a single bloated doc cannot push
the digest dir out of useful range.

Defaults:
    MAX_LINES = 100
    MAX_BYTES = 5_000

All files are optional. The hook is silent on any file that does not exist.

Usage (when run directly):
    python3 scripts/check-catalog-doc-size.py            # check all three files

Canonical copy lives in coilysiren/agentic-os/scripts/. Each consumer repo
gets a stamped copy via agentic-os-kai's apply-catalog-doc-size-hook
rollout. Exits 0 on clean, 1 on any cap breach with a per-file report on
stderr.

See coilysiren/agentic-os-kai#545 for the design.
"""
from __future__ import annotations

import sys
from pathlib import Path

MAX_LINES = 100
MAX_BYTES = 5_000

CHECKED_FILES = [
    Path("README.md"),
    Path("AGENTS.md"),
    Path("docs/FEATURES.md"),
]


def check_file(path: Path) -> list[str]:
    if not path.is_file():
        return []
    n_lines = sum(1 for _ in path.open(encoding="utf-8", errors="replace"))
    n_bytes = path.stat().st_size
    violations: list[str] = []
    if n_lines > MAX_LINES:
        violations.append(
            f"{path}: {n_lines} lines exceeds the {MAX_LINES}-line cap. "
            f"This file is pulled wholesale into agentic-os-kai's per-repo "
            f"digest; move detail into a sibling docs/ file. See "
            f"coilysiren/agentic-os-kai#545."
        )
    if n_bytes > MAX_BYTES:
        violations.append(
            f"{path}: {n_bytes} bytes exceeds the {MAX_BYTES}-byte cap. "
            f"This file is pulled wholesale into agentic-os-kai's per-repo "
            f"digest; trim or split. See coilysiren/agentic-os-kai#545."
        )
    return violations


def main() -> int:
    all_violations: list[str] = []
    for rel in CHECKED_FILES:
        all_violations.extend(check_file(rel))

    if not all_violations:
        print("catalog-doc-size check: OK")
        return 0

    for v in all_violations:
        sys.stderr.write(f"FAIL: {v}\n")
    sys.stderr.write(f"\n{len(all_violations)} cap breach(es).\n")
    return 1


if __name__ == "__main__":
    sys.exit(main())
