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

# Output is NOT discarded. An earlier version sent it to /dev/null, so when
# sync failed in CI the only symptom was "'technical' vocabulary not found"
# from the next command -- the actual cause was invisible.
echo "syncing style package..."
vale --config=.vale.ini sync

# Fail loudly if the sync did not produce what the config declares it needs,
# rather than letting Vale report a confusing downstream error.
if [ ! -d ".vale/config/vocabularies/technical" ]; then
  echo "sync completed but .vale/config/vocabularies/technical is absent" >&2
  echo "contents of .vale:" >&2
  find .vale -maxdepth 3 >&2 || true
  exit 1
fi
# .specify/ and .claude/ are vendored and hashed by the specify CLI; linting
# them would report defects nobody may fix (FR-033).
mapfile -t files < <(git ls-files '*.md' | grep -vE '^(\.specify|\.claude)/')
vale --config=.vale.ini "${files[@]}"
