#!/usr/bin/env bash
# Manifest integrity class (FR-033).
#
# Verifies that no file hashed in `.specify/integrations/*.json` was hand-edited.
# Those files are vendored by the `specify` CLI; a local edit drifts from the
# manifest and is overwritten on the next upgrade, losing the work silently.
#
# Implemented in Python for the same reason as the link class: JSON and SHA256 in
# bash means jq plus sha256sum plus a subshell per file, and the first version
# written that way reported "0 files checked" as a pass because it guessed the
# manifest's shape wrongly.
set -euo pipefail
exec python3 "$(dirname "$0")/check_manifest_integrity.py" "$@"
