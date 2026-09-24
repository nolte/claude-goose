#!/usr/bin/env bash
# Portability class.
#
# Verifies Constitution Principle I: process/ and baselines/ must be usable in a
# foreign repository without editing them. Anything subject- or
# repository-specific must arrive as a declared input.
#
# The three checks are specified in tests/goose-implementation-review/PORTABILITY.md
# and were previously a procedure a human was expected to remember. They are
# implemented here because this feature adds the first executable file to the
# reusable tree, and a shell script is precisely where an absolute path gets
# hard-coded during debugging.
#
# Check 3 scans BOTH trees. An earlier version scanned only process/ and passed
# while baselines/ held a real violation; PORTABILITY.md records that under
# "Guard history". A passing check with the wrong scope is more dangerous than
# no check, since it is reported as evidence.
set -euo pipefail

trees=(process baselines skills)
for t in "${trees[@]}"; do
  [ -d "$t" ] || { echo "portability: missing tree: $t" >&2; exit 2; }
done

fail=0
note() {
  echo "  FAIL  $1" >&2
  fail=1
}

# 1. This repository's own name must not appear in the reusable trees.
if hits=$(grep -rIn --exclude-dir=.git -- 'claude-goose' "${trees[@]}" 2>/dev/null); then
  note "repository name leaked into a reusable tree"
  echo "$hits" | sed 's/^/        /' >&2
fi

# 2. No absolute paths into a developer's machine.
if hits=$(grep -rInE --exclude-dir=.git -- '(/home/|/Users/|[A-Za-z]:\\)' "${trees[@]}" 2>/dev/null); then
  note "absolute path leaked into a reusable tree"
  echo "$hits" | sed 's/^/        /' >&2
fi

# 3. No references to this project's spec tree — consumers never receive it.
#    Upstream documentation URLs in a baseline's sources.md are deliberately not
#    covered: those are a property of the criteria and must travel with them.
if hits=$(grep -rIn --exclude-dir=.git -- 'specs/[0-9]' "${trees[@]}" 2>/dev/null); then
  note "reference to this project's spec directory in a reusable tree"
  echo "$hits" | sed 's/^/        /' >&2
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: no repository-specific values found in ${trees[*]}"
fi
exit "$fail"
