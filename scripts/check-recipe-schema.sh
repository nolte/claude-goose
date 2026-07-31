#!/usr/bin/env bash
# Recipe schema class (FR-003).
#
# Checks the documented required fields and parameter rules without invoking
# Goose. The parse class (check-recipe-parse.sh) delegates to the host itself;
# this class states the expectations explicitly so a failure names the rule
# rather than echoing a terse parser error.
#
# Rules are sourced from the Recipe Reference Guide, consulted 2026-07-31:
#   - title and description are required
#   - at least one of instructions or prompt must be present
#   - optional parameters must have default values
#   - file parameters must not have default values
set -euo pipefail

recipe="${1:?usage: check-recipe-schema.sh <recipe.yaml>}"
[ -f "$recipe" ] || { echo "recipe not found: $recipe" >&2; exit 1; }

fail=0
note() { echo "  FAIL  $1" >&2; fail=1; }

python3 - "$recipe" <<'PY' || fail=1
import sys, yaml

path = sys.argv[1]
with open(path) as fh:
    doc = yaml.safe_load(fh)

problems = []

for key in ("title", "description"):
    if not doc.get(key):
        problems.append(f"required field '{key}' is absent or empty")

if not doc.get("instructions") and not doc.get("prompt"):
    problems.append("neither 'instructions' nor 'prompt' is present")

for p in doc.get("parameters") or []:
    key = p.get("key", "<unnamed>")
    requirement = p.get("requirement")
    has_default = "default" in p
    if requirement == "optional" and not has_default:
        problems.append(f"optional parameter '{key}' has no default")
    if p.get("input_type") == "file" and has_default:
        problems.append(f"file parameter '{key}' carries a default")

for line in problems:
    print(f"  FAIL  {line}", file=sys.stderr)

sys.exit(1 if problems else 0)
PY

if [ "$fail" -eq 0 ]; then
  echo "recipe schema: ok ($recipe)"
fi
exit "$fail"
