#!/usr/bin/env bash
# Prose lint class (FR-005).
#
# Syncs the pinned style package first: without it Vale exits 2 on a missing
# StylesPath, which looks like a prose failure but is a configuration error.
set -euo pipefail

if ! command -v vale >/dev/null 2>&1; then
  echo "vale not installed — prose class cannot run" >&2
  echo "This is a hard failure, not a skip (FR-010)." >&2
  exit 1
fi

vale --config=.vale.ini sync >/dev/null
# .specify/ and .claude/ are vendored and hashed by the specify CLI; linting
# them would report defects nobody may fix (FR-033).
mapfile -t files < <(git ls-files '*.md' | grep -vE '^(\.specify|\.claude)/')
vale --config=.vale.ini "${files[@]}"
