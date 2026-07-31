#!/usr/bin/env python3
"""Internal link class (FR-004): relative links and anchors, offline only."""
from __future__ import annotations
import re
import sys
from pathlib import Path

LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
SKIP_DIRS = {".git", ".specify", "node_modules", ".github/styles"}
EXTERNAL = ("http://", "https://", "mailto:", "tel:")


def anchors(text: str) -> set[str]:
    """Heading anchors, GitHub-style: lowercase, spaces to hyphens, punctuation dropped."""
    found = set()
    for line in text.splitlines():
        if line.startswith("#"):
            title = line.lstrip("#").strip()
            slug = re.sub(r"[^\w\s-]", "", title.lower())
            found.add(re.sub(r"\s+", "-", slug).strip("-"))
    return found


def main() -> int:
    root = Path(".")
    failures: list[str] = []
    checked = 0

    for md in sorted(root.rglob("*.md")):
        if any(part in SKIP_DIRS for part in md.parts):
            continue
        text = md.read_text(encoding="utf-8", errors="replace")
        own_anchors = anchors(text)

        for target in LINK.findall(text):
            if target.startswith(EXTERNAL):
                continue
            checked += 1
            path_part, _, anchor = target.partition("#")

            if not path_part:                      # same-document anchor
                if anchor and anchor.lower() not in own_anchors:
                    failures.append(f"{md}: anchor '#{anchor}' has no matching heading")
                continue

            resolved = (md.parent / path_part).resolve()
            if not resolved.exists():
                failures.append(f"{md}: '{path_part}' does not exist")

    for f in failures:
        print(f"  FAIL  {f}", file=sys.stderr)

    if failures:
        print(f"internal links: {len(failures)} broken of {checked} checked", file=sys.stderr)
        return 1
    print(f"internal links: ok ({checked} checked)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
