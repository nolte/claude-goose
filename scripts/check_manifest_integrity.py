#!/usr/bin/env python3
"""Manifest integrity class (FR-033).

The `specify` CLI vendors the Spec Kit skills, scripts, and templates, and
records a SHA256 for each in `.specify/integrations/*.json`. A local edit to any
of them drifts from the manifest and is overwritten on the next upgrade -- the
work is lost silently, which is why this is a gate class rather than advice in a
document.

The manifest shape is `{"files": {"<path>": "<sha256>", ...}}`, a flat mapping.
Writing this check against a guessed shape produced "0 files checked, 0 drifted"
-- a pass that verified nothing. The count of hashed files is therefore always
reported, and an empty manifest is a failure, not a silent success.
"""

from __future__ import annotations

import hashlib
import json
import pathlib
import sys

MANIFEST_GLOB = ".specify/integrations/*.json"


def main() -> int:
    root = pathlib.Path.cwd()
    manifests = sorted(root.glob(MANIFEST_GLOB))

    if not manifests:
        print(f"error: no manifest matched {MANIFEST_GLOB}", file=sys.stderr)
        return 1

    total = 0
    drifted: list[str] = []
    missing: list[str] = []

    for manifest in manifests:
        try:
            data = json.loads(manifest.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            print(f"error: cannot read {manifest}: {exc}", file=sys.stderr)
            return 1

        files = data.get("files")
        if not isinstance(files, dict) or not files:
            print(
                f"error: {manifest} has no usable 'files' mapping "
                f"(got {type(files).__name__}); the manifest format may have changed",
                file=sys.stderr,
            )
            return 1

        for rel, expected in sorted(files.items()):
            total += 1
            target = root / rel
            if not target.exists():
                missing.append(rel)
                continue
            actual = hashlib.sha256(target.read_bytes()).hexdigest()
            if actual.lower() != str(expected).lower():
                drifted.append(f"{rel}\n    manifest {expected}\n    actual   {actual}")

        print(
            f"{manifest.name}: {len(files)} hashed files "
            f"(specify v{data.get('version', 'unknown')})"
        )

    for rel in missing:
        print(f"MISSING  {rel}", file=sys.stderr)
    for entry in drifted:
        print(f"DRIFT    {entry}", file=sys.stderr)

    if drifted or missing:
        print(
            f"\n{len(drifted)} hand-edited and {len(missing)} missing of {total} "
            "vendored files.\n"
            "These are managed by the specify CLI. Customise through "
            ".specify/templates/overrides/ or a skill without the speckit- prefix; "
            "restore the originals with a specify upgrade.",
            file=sys.stderr,
        )
        return 1

    print(f"{total} vendored files verified against their manifests, none hand-edited.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
