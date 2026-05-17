#!/usr/bin/env python3
"""Strip GUI-induced thrash from warp/settings.toml on commit.

Warp persists transient GUI state (zoom level, host-absolute theme paths)
back into settings.toml on every nudge. Without a normalizer the file
churns every commit and breaks portability across hosts.

Two surgical fixes, regex-based to preserve TOML comments and layout:

1. Remove `zoom_level` lines under `[appearance.window]`. Collapse the
   section header if no keys remain.
2. Rewrite `path = "<abs>/.warp/themes/<file>"` inside custom-theme
   blocks to `path = "~/.warp/themes/<file>"` so Warp expands per-host.

Auto-fix mode: edits files in place, exits 1 if any file changed, 0
otherwise. Standard pre-commit auto-fix contract.

Origin: coilysiren/agentic-os#80.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


WARP_THEMES_PATH_RE = re.compile(
    r'(path\s*=\s*")(?P<abs>/[^"]*?/\.warp/themes/)(?P<file>[^"/]+\.ya?ml)(")',
)


def strip(text: str) -> str:
    out = _strip_zoom_level(text)
    out = _normalize_theme_path(out)
    return out


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


def _normalize_theme_path(text: str) -> str:
    def repl(m: re.Match[str]) -> str:
        return f'{m.group(1)}~/.warp/themes/{m.group("file")}{m.group(4)}'

    return WARP_THEMES_PATH_RE.sub(repl, text)


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
