#!/usr/bin/env bash
# Recipe parse class (FR-006).
#
# Delegates to the host's own parser via `goose run --explain`, which loads and
# validates a recipe without any model call. This is the strongest of the seven
# classes: it exercises the real implementation rather than a schema this
# project wrote, and it costs nothing.
#
# Feature 001 measured that five of its ten baseline criteria are enforced by
# exactly this parser.
set -euo pipefail

recipe="${1:?usage: check-recipe-parse.sh <recipe.yaml>}"

if ! command -v goose >/dev/null 2>&1; then
  echo "goose not installed — recipe parse class cannot run" >&2
  echo "This is a hard failure, not a skip: a class that silently passes when" >&2
  echo "its tool is missing reports coverage that does not exist (FR-010)." >&2
  exit 1
fi

out="$(goose run --recipe "$recipe" --explain 2>&1)" || true
if printf '%s' "$out" | grep -q '^Error:'; then
  echo "recipe parse: REJECTED by the host" >&2
  printf '%s\n' "$out" | grep '^Error:' | sed 's/^/  /' >&2
  exit 1
fi

echo "recipe parse: ok ($recipe)"
