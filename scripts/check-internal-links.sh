#!/usr/bin/env bash
# Internal link class (FR-004).
#
# Relative file links and intra-document anchors only. External URLs are NOT
# checked: their reachability depends on the network, which would make the gate
# non-deterministic and violate FR-011. That omission is recorded in
# OMISSIONS.md rather than left implicit.
#
# Implemented in Python rather than grep pipelines: an earlier bash version
# exited silently under `set -e` whenever a file contained no links at all,
# reporting failure without naming one. A check that fails without saying why
# is as useless as one that cannot fail.
set -euo pipefail
exec python3 "$(dirname "$0")/check_internal_links.py" "$@"
