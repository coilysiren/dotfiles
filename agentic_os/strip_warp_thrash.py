#!/usr/bin/env python3
"""Strip GUI-induced thrash from warp/settings.toml on commit.

Warp persists transient GUI state (zoom level) back into settings.toml on
every nudge. Without a normalizer the file churns every commit.

Regex-based to preserve TOML comments and layout. Removes `zoom_level`
lines under `[appearance.window]`. Collapses the section header if no
keys remain.

Auto-fix mode: edits files in place, exits 1 if any file changed, 0
otherwise. Standard pre-commit auto-fix contract.

Theme `path` normalization was tried in the first cut (#80) and reverted
in #81 because Warp does not expand `~` in theme paths. Cross-host theme
portability needs a heavier template-on-setup approach, tracked separately.

Origin: coilysiren/agentic-os#80, #81.
"""

from __future__ import annotations

import sys
from pathlib import Path


def strip(text: str) -> str:
    return _strip_zoom_level(text)


def _strip_zoom_level(text: str) -> str:
    lines = text.splitlines(keepends=True)
    result: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.strip() == "[appearance.window]":
            section: list[str] = [line]
            j = i + 1
            kept_keys = 0
            while j < len(lines) and not _is_section_header(lines[j]):
                stripped = lines[j].strip()
                if stripped.startswith("zoom_level"):
                    j += 1
                    continue
                section.append(lines[j])
                if stripped and not stripped.startswith("#"):
                    kept_keys += 1
                j += 1
            if kept_keys == 0:
                while section and section[-1].strip() == "":
                    section.pop()
                if len(section) == 1:
                    i = j
                    while i < len(lines) and lines[i].strip() == "":
                        i += 1
                    continue
            result.extend(section)
            i = j
            continue
        result.append(line)
        i += 1
    return "".join(result)


def _is_section_header(line: str) -> bool:
    stripped = line.strip()
    return stripped.startswith("[") and stripped.endswith("]")


def main(argv: list[str] | None = None) -> int:
    args = argv if argv is not None else sys.argv[1:]
    if not args:
        print("usage: strip-warp-thrash <file>...", file=sys.stderr)
        return 2
    changed = False
    for arg in args:
        path = Path(arg)
        if not path.exists():
            print(f"strip-warp-thrash: skip missing {path}", file=sys.stderr)
            continue
        original = path.read_text()
        fixed = strip(original)
        if fixed != original:
            path.write_text(fixed)
            print(f"strip-warp-thrash: rewrote {path}")
            changed = True
    return 1 if changed else 0


if __name__ == "__main__":
    raise SystemExit(main())
